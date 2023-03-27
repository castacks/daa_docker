import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.models as models
import timm
from transformers import BertModel, BertTokenizer, BertConfig

torch.hub._validate_not_a_forked_repo = lambda a, b, c: True

models = {
    "alexnet": {
        "model": models.alexnet(pretrained=True),
        "path": "both"
    },
    "vgg16": {
        "model": models.vgg16(pretrained=True),
        "path": "both"
    },
    "squeezenet": {
        "model": models.squeezenet1_0(pretrained=True),
        "path": "both"
    },
    "densenet": {
        "model": models.densenet161(pretrained=True),
        "path": "both"
    },
    "inception_v3": {
        "model": models.inception_v3(pretrained=True),
        "path": "both"
    },
    #"googlenet": models.googlenet(pretrained=True),
    "shufflenet": {
        "model": models.shufflenet_v2_x1_0(pretrained=True),
        "path": "both"
    },
    "mobilenet_v2": {
        "model": models.mobilenet_v2(pretrained=True),
        "path": "both"
    },
    "resnext50_32x4d": {
        "model": models.resnext50_32x4d(pretrained=True),
        "path": "both"
    },
    "wideresnet50_2": {
        "model": models.wide_resnet50_2(pretrained=True),
        "path": "both"
    },
    "mnasnet": {
        "model": models.mnasnet1_0(pretrained=True),
        "path": "both"
    },
    "resnet18": {
        "model": torch.hub.load('pytorch/vision:v0.9.0', 'resnet18', pretrained=True),
        "path": "both"
    },
    "resnet50": {
        "model": torch.hub.load('pytorch/vision:v0.9.0', 'resnet50', pretrained=True),
        "path": "both"
    },
    "ssd": {
        "model": torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_ssd', model_math="fp32"),
        "path": "trace"
    },
    "efficientnet_b0": {
        "model": timm.create_model('efficientnet_b0', pretrained=True),
        "path": "script"
    },
    "vit": {
        "model": timm.create_model('vit_base_patch16_224', pretrained=True),
        "path": "script"
    }
}

# Download sample models
for n, m in models.items():
    print("Downloading {}".format(n))
    m["model"] = m["model"].eval().cuda()
    x = torch.ones((1, 3, 300, 300)).cuda()
    if m["path"] == "both" or m["path"] == "trace":
        trace_model = torch.jit.trace(m["model"], [x])
        torch.jit.save(trace_model, n + '_traced.jit.pt')
    if m["path"] == "both" or m["path"] == "script":
        script_model = torch.jit.script(m["model"])
        torch.jit.save(script_model, n + '_scripted.jit.pt')


# Sample Pool Model (for testing plugin serialization)
class Pool(nn.Module):

    def __init__(self):
        super(Pool, self).__init__()

    def forward(self, x):
        return F.adaptive_avg_pool2d(x, (5, 5))


model = Pool().eval().cuda()
x = torch.ones([1, 3, 10, 10]).cuda()

trace_model = torch.jit.trace(model, x)
torch.jit.save(trace_model, "pooling_traced.jit.pt")


# Sample Nested Module (for module-level fallback testing)
class ModuleFallbackSub(nn.Module):

    def __init__(self):
        super(ModuleFallbackSub, self).__init__()
        self.conv = nn.Conv2d(1, 3, 3)
        self.relu = nn.ReLU()

    def forward(self, x):
        return self.relu(self.conv(x))


class ModuleFallbackMain(nn.Module):

    def __init__(self):
        super(ModuleFallbackMain, self).__init__()
        self.layer1 = ModuleFallbackSub()
        self.conv = nn.Conv2d(3, 6, 3)
        self.relu = nn.ReLU()

    def forward(self, x):
        return self.relu(self.conv(self.layer1(x)))


module_fallback_model = ModuleFallbackMain().eval().cuda()
module_fallback_script_model = torch.jit.script(module_fallback_model)
torch.jit.save(module_fallback_script_model, "module_fallback_scripted.jit.pt")


# Sample Looping Modules (for loop fallback testing)
class LoopFallbackEval(nn.Module):

    def __init__(self):
        super(LoopFallbackEval, self).__init__()

    def forward(self, x):
        add_list = torch.empty(0).to(x.device)
        for i in range(x.shape[1]):
            add_list = torch.cat((add_list, torch.tensor([x.shape[1]]).to(x.device)), 0)
        return x + add_list


class LoopFallbackNoEval(nn.Module):

    def __init__(self):
        super(LoopFallbackNoEval, self).__init__()

    def forward(self, x):
        for _ in range(x.shape[1]):
            x = x + torch.ones_like(x)
        return x


loop_fallback_eval_model = LoopFallbackEval().eval().cuda()
loop_fallback_eval_script_model = torch.jit.script(loop_fallback_eval_model)
torch.jit.save(loop_fallback_eval_script_model, "loop_fallback_eval_scripted.jit.pt")
loop_fallback_no_eval_model = LoopFallbackNoEval().eval().cuda()
loop_fallback_no_eval_script_model = torch.jit.script(loop_fallback_no_eval_model)
torch.jit.save(loop_fallback_no_eval_script_model, "loop_fallback_no_eval_scripted.jit.pt")


# Sample Conditional Model (for testing partitioning and fallback in conditionals)
class FallbackIf(torch.nn.Module):

    def __init__(self):
        super(FallbackIf, self).__init__()
        self.relu1 = torch.nn.ReLU()
        self.conv1 = torch.nn.Conv2d(3, 32, 3, 1, 1)
        self.log_sig = torch.nn.LogSigmoid()
        self.conv2 = torch.nn.Conv2d(32, 32, 3, 1, 1)
        self.conv3 = torch.nn.Conv2d(32, 3, 3, 1, 1)

    def forward(self, x):
        x = self.relu1(x)
        x_first = x[0][0][0][0].item()
        if x_first > 0:
            x = self.conv1(x)
            x1 = self.log_sig(x)
            x2 = self.conv2(x)
            x = self.conv3(x1 + x2)
        else:
            x = self.log_sig(x)
        x = self.conv1(x)
        return x


conditional_model = FallbackIf().eval().cuda()
conditional_script_model = torch.jit.script(conditional_model)
torch.jit.save(conditional_script_model, "conditional_scripted.jit.pt")

enc = BertTokenizer.from_pretrained("bert-base-uncased")
text = "[CLS] Who was Jim Henson ? [SEP] Jim Henson was a puppeteer [SEP]"
tokenized_text = enc.tokenize(text)
masked_index = 8
tokenized_text[masked_index] = "[MASK]"
indexed_tokens = enc.convert_tokens_to_ids(tokenized_text)
segments_ids = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1]
tokens_tensor = torch.tensor([indexed_tokens])
segments_tensors = torch.tensor([segments_ids])
dummy_input = [tokens_tensor, segments_tensors]

config = BertConfig(
    vocab_size_or_config_json_file=32000,
    hidden_size=768,
    num_hidden_layers=12,
    num_attention_heads=12,
    intermediate_size=3072,
    torchscript=True,
)

model = BertModel(config)
model.eval()
model = BertModel.from_pretrained("bert-base-uncased", torchscript=True)

traced_model = torch.jit.trace(model, [tokens_tensor, segments_tensors])
torch.jit.save(traced_model, "bert_base_uncased_traced.jit.pt")
