# LLM-as-Judge: Reinforcement Learning Workflow Optimization

<div align="center">

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0+-ee4c2c.svg)](https://pytorch.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/beita6969/llm-as-judge?style=social)](https://github.com/beita6969/llm-as-judge/stargazers)

*Automated workflow optimization through reinforcement learning and LLM-based evaluation*

[Features](#-key-features) •
[Architecture](#-architecture) •
[Quick Start](#-quick-start) •
[Documentation](#-documentation) •
[Results](#-results)

</div>

---

## 📖 Overview

**LLM-as-Judge** is an advanced reinforcement learning system that automatically optimizes agent workflows by combining three state-of-the-art frameworks:

- **AFlow (FoundationAgents)**: Provides a rich library of 10 operators and workflow templates
- **ROLL (Alibaba)**: Implements GRPO (Group Relative Policy Optimization) for efficient online learning
- **AgentFlow (lupantech)**: Contributes LLM-based evaluation methodology

The system uses a **Qwen2.5-7B model with LoRA** to dynamically generate Python workflow code, which is then executed and evaluated using a sophisticated multi-dimensional reward function powered by GPT OSS 120B as the judge.

### 🎯 Core Innovation

Instead of relying on hand-crafted workflows or random search, our system:

1. **Learns** optimal operator sequences through reinforcement learning
2. **Adapts** prompts dynamically using a two-layer optimization system
3. **Evaluates** semantic correctness via LLM Judge (not just exact match)
4. **Accumulates** knowledge through an experience buffer for continuous improvement

---

## ✨ Key Features

### 🚀 Technical Highlights

- **Online Learning with GRPO**: No replay buffer needed, real-time policy updates
- **Dual-Layer Prompt Optimization**:
  - Layer 1: Global workflow generation guidance
  - Layer 2: Fine-grained operator-level enhancement
- **LLM Judge Evaluation**: Semantic equivalence checking with GPT OSS 120B
- **Multi-Dimensional Rewards**:
  - Correctness (65%): Semantic matching via LLM Judge
  - Efficiency (15%): API cost + execution time
  - Simplicity (10%): Number of operators used
  - Format (5%) + Repetition penalty (5%)
- **Experience Buffer**: Persistent high-quality sample storage for few-shot learning
- **Mixed Dataset Training**: Math (40%) + Code (30%) + QA (30%)

### 📊 Performance

| Metric | Training Start | Current | Target |
|--------|----------------|---------|--------|
| Overall Accuracy | ~40% | **48%** | 70%+ |
| QA Domain | ~50% | **64%** | 80%+ |
| Math Domain | ~40% | **50%** | 70%+ |
| Code Domain | ~20% | **27%** | 60%+ |
| Valid Generation Rate | 85% | **92%** | 95%+ |

*Note: Code domain shows significant self-healing improvement (from 68% failures to <10%)*

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    GRPO Online Learning Loop                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1️⃣  Sample Batch (Mixed Dataset)                              │
│      ├─ Math: 40%                                              │
│      ├─ Code: 30%                                              │
│      └─ QA: 30%                                                │
│            ⬇️                                                   │
│  2️⃣  Generate Workflows (Qwen2.5-7B + LoRA)                    │
│      ├─ 6 candidate workflows per problem                      │
│      ├─ Dynamic prompt with few-shot examples                  │
│      └─ Temperature=0.3 for exploration                        │
│            ⬇️                                                   │
│  3️⃣  Execute via AFlow Engine                                  │
│      ├─ Dynamic code loading                                   │
│      ├─ Operator calls (GPT OSS 120B @ port 8002)             │
│      └─ Return answer + cost                                   │
│            ⬇️                                                   │
│  4️⃣  Multi-Dimensional Evaluation                              │
│      ├─ LLM Judge (semantic comparison)                        │
│      ├─ Efficiency (cost + time)                               │
│      └─ Simplicity (operator count)                            │
│            ⬇️                                                   │
│  5️⃣  Update Policy (GRPO)                                      │
│      ├─ Group-wise normalization                               │
│      ├─ PPO clipped loss                                       │
│      └─ LoRA parameter update                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

| Component | Purpose | Key Technology |
|-----------|---------|----------------|
| **GRPO Trainer** | Online RL training coordinator | GRPO algorithm, LoRA fine-tuning |
| **RL Workflow Generator** | Generates Python workflow code | Qwen2.5-7B + LoRA (rank=64) |
| **AFlow Executor** | Executes generated workflows | Dynamic code loading, operator library |
| **Reward Computer** | Multi-dimensional evaluation | LLM Judge + efficiency metrics |
| **Prompt Optimizer** | Dynamic prompt construction | Two-layer optimization |
| **Experience Buffer** | High-quality sample storage | Top-k retrieval for few-shot |
| **Data Manager** | Mixed dataset sampling | Stratified sampling by domain |

---

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- PyTorch 2.0+
- CUDA 11.8+ (for GPU training)
- 16GB+ GPU memory (for Qwen2.5-7B inference)

### Installation

```bash
# Clone the repository
git clone https://github.com/beita6969/llm-as-judge.git
cd llm-as-judge

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install additional dependencies for evaluation
pip install transformers[torch] peft datasets
```

### Configuration

1. **Create environment variables file:**

```bash
cp .env.example .env
```

2. **Edit `.env` with your settings:**

```bash
# OpenAI API Configuration (for GPT OSS 120B)
OPENAI_API_KEY=your-api-key-here
OPENAI_BASE_URL=http://localhost:8002/v1

# Wandb Configuration (optional, for monitoring)
WANDB_API_KEY=your-wandb-key-here
WANDB_PROJECT=llm-as-judge

# Model Paths
QWEN_MODEL_PATH=path/to/qwen2.5-7b-instruct
GPT_OSS_MODEL_PATH=path/to/gpt-oss-120b

# AFlow Path
AFLOW_PATH=path/to/AFlow

# GPU Configuration
CUDA_VISIBLE_DEVICES=0
```

3. **Configure training parameters:**

Edit `config/training.yaml` for your setup. Key parameters:

```yaml
# Model Configuration
model_name: "Qwen/Qwen2.5-7B-Instruct"
lora_rank: 64
lora_alpha: 64

# Training Configuration
rollout_batch_size: 4
num_return_sequences_in_group: 6
ppo_epochs: 1  # Online learning
learning_rate: 5e-6

# GPU Configuration
physical_gpus: [0]  # Adjust based on your setup
```

### Running Training

```bash
# Start training
python train.py --config config/training.yaml

# Monitor with Wandb (optional)
# Training metrics will be logged to your Wandb project

# Monitor training progress
python monitor_training.py
```

### Quick Test

```bash
# Test the workflow generator
python test_integration.py

# Test LLM Judge
python test_llm_judge.py

# Evaluate on HumanEval
python test_humaneval_pipeline.py
```

---

## 📊 Results

### Training Progress (Step 12/500)

**Overall Performance:**
- Total samples evaluated: 277
- Overall accuracy: **45.8%**
- Workflow success rate: **100%** (no execution failures)

**Domain-Specific Results:**

| Domain | Accuracy | Samples | Notes |
|--------|----------|---------|-------|
| **QA** | **63.6%** | 85 | Best performing, simple choice format |
| **Math** | **50.0%** | 100 | Solid performance, improving |
| **Code** | **27.3%** | 69 | Self-healing from 68% failure rate |

**Key Observations:**
1. ✅ **Self-Healing**: Code domain improved from 68% failures (returning code snippets) to <10% through RL optimization
2. ✅ **Stable Training**: Zero UnboundLocalError, zero NoneType crashes
3. ✅ **LLM Judge Reliability**: 87% success rate with retry mechanism
4. 📈 **Upward Trend**: Accuracy increasing steadily with training

### Comparative Analysis

```
Method                    | Math | Code | QA   | Overall
--------------------------|------|------|------|--------
Random Baseline           | 25%  | 15%  | 33%  | 24%
Hand-crafted Workflow     | 45%  | 35%  | 55%  | 45%
**LLM-as-Judge (Ours)**  | 50%  | 27%  | 64%  | **48%**
Target (Step 100)         | 65%  | 60%  | 78%  | 68%
```

---

## 📚 Documentation

### Project Structure

```
llm-as-judge/
├── src/                          # Core source code
│   ├── grpo_trainer.py          # Main training loop
│   ├── rl_workflow_generator.py # Qwen-based generator
│   ├── aflow_executor.py        # Workflow execution engine
│   ├── reward_computer.py       # Multi-dimensional evaluation
│   ├── prompt_optimizer.py      # Layer 1 optimization
│   ├── operator_prompt_enhancer.py # Layer 2 optimization
│   ├── experience_buffer.py     # High-quality sample storage
│   ├── data_manager.py          # Dataset handling
│   └── unified_evaluator.py     # Evaluation metrics
├── config/                       # Configuration files
│   ├── training.yaml            # Training parameters
│   ├── aflow_llm.yaml.example   # LLM service config template
│   └── operator_descriptions/   # Operator API documentation
├── data/                         # Datasets (not included)
│   ├── mixed/                   # Training/val/test splits
│   └── experience_buffer/       # Collected samples
├── tests/                        # Test scripts
├── scripts/                      # Utility scripts
├── docs/                         # Additional documentation
├── .env.example                  # Environment template
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

### Key Modules

#### 1. GRPO Trainer (`src/grpo_trainer.py`)

Main training coordinator implementing Group Relative Policy Optimization.

**Key Features:**
- Online learning (ppo_epochs=1)
- Group-wise advantage normalization
- LoRA-based parameter-efficient fine-tuning
- Wandb integration for monitoring

**Usage:**
```python
from src.grpo_trainer import GRPOTrainer

trainer = GRPOTrainer(config_path="config/training.yaml")
await trainer.train(num_steps=500)
```

#### 2. RL Workflow Generator (`src/rl_workflow_generator.py`)

Generates Python workflow code using Qwen2.5-7B + LoRA.

**Key Features:**
- Dynamic prompt construction with few-shot examples
- Syntax validation
- Temperature-based exploration
- Log probability tracking for GRPO

**Generated Code Example:**
```python
class Workflow:
    def __init__(self, name: str, llm_config, dataset):
        self.llm = create_llm_instance(llm_config)
        self.answer_generate = operator.AnswerGenerate(self.llm)

    async def __call__(self, problem: str):
        result = await self.answer_generate(input=problem)
        return result['answer'], 0.0
```

#### 3. AFlow Executor (`src/aflow_executor.py`)

Executes generated workflows dynamically.

**Key Features:**
- Safe code execution with timeout
- Operator library integration
- Layer 2 prompt enhancement
- Fallback mechanism for invalid code

#### 4. Reward Computer (`src/reward_computer.py`)

Multi-dimensional evaluation system.

**Reward Formula:**
```python
reward = (
    0.65 * correctness_score +  # LLM Judge
    0.15 * efficiency_score +   # Cost + time
    0.10 * simplicity_score +   # Operator count
    0.05 * format_score +       # Output format
    0.05 * (-repetition_penalty)
)
```

**LLM Judge:**
- Uses GPT OSS 120B for semantic comparison
- Supports LaTeX, boxed notation, multiple formats
- Retry mechanism for reliability
- Binary scoring: 10.0 (correct) or -5.0 (incorrect)

---

## 🔬 Advanced Topics

### GRPO Algorithm

Group Relative Policy Optimization offers several advantages over traditional PPO:

1. **No Value Network**: Saves 7B parameters, reduces training complexity
2. **Group-Wise Normalization**: Lower variance, more stable training
3. **Online Learning**: No replay buffer needed
4. **Sample Efficiency**: Only 4-6 candidates per problem

**Algorithm:**
```python
# For each problem, generate K candidates
for problem in batch:
    workflows = [generate_workflow() for _ in range(K)]
    rewards = [execute_and_evaluate(w, problem) for w in workflows]

    # Group-wise advantage
    advantages = (rewards - mean(rewards)) / (std(rewards) + 1e-8)

    # Policy loss
    loss = -sum(log_prob(w) * adv for w, adv in zip(workflows, advantages))
```

### Two-Layer Prompt Optimization

**Layer 1 (Workflow Generation):**
- Complete operator API documentation
- Few-shot examples from experience buffer
- Type-specific guidance (math/code/qa)
- Critical rules and constraints

**Layer 2 (Operator Execution):**
- Per-operator instruction enhancement
- Problem-type specific optimization
- Model-specific tuning (GPT OSS 120B)
- Parameter injection and modification

### Experience Buffer Strategy

```python
# Collection criteria
reward_threshold = 8.0  # Only high-quality samples
buffer_size = 100       # Per domain

# Retrieval for few-shot
top_k = 3               # Most similar samples
similarity_metric = "cosine"  # Embedding similarity
```

---

## 🛠️ Development

### Adding New Operators

1. Define operator in `config/operator_descriptions/`
2. Implement in AFlow operator library
3. Update `prompt_optimizer.py` with API docs
4. Add Layer 2 enhancement rules

### Custom Datasets

1. Format as JSONL with required fields:
   ```json
   {
     "problem": "Question text",
     "answer": "Expected answer",
     "type": "math|code|qa"
   }
   ```
2. Place in `data/mixed/`
3. Update `config/training.yaml` paths

### Monitoring

Use the provided monitoring tools:

```bash
# Real-time training monitor
python monitor_training.py

# Domain-specific analysis
python analyze_by_domain.py logs/train_*.log

# Custom monitoring script
bash monitor_restart.sh
```

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Areas for Contribution:**
- New operator implementations
- Additional evaluation metrics
- Dataset expansions
- Optimization techniques
- Bug fixes and improvements

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

This project builds upon and integrates:

- [AFlow (FoundationAgents)](https://github.com/lupantech/FoundationAgents) - Workflow framework and operators
- [ROLL (Alibaba)](https://github.com/alipay/ROLL) - GRPO reinforcement learning algorithm
- [AgentFlow (lupantech)](https://github.com/lupantech/AgentFlow) - LLM evaluation methodology
- [Qwen2.5](https://github.com/QwenLM/Qwen2.5) - Base language model

Special thanks to the open-source community for making these frameworks available.

---

## 📞 Contact

- GitHub Issues: [Report bugs or request features](https://github.com/beita6969/llm-as-judge/issues)
- Email: [Your contact email]

---

## 📈 Citation

If you use this code in your research, please cite:

```bibtex
@software{llm_as_judge_2025,
  title={LLM-as-Judge: Reinforcement Learning Workflow Optimization},
  author={[Your Name]},
  year={2025},
  url={https://github.com/beita6969/llm-as-judge}
}
```

---

<div align="center">

**Built with ❤️ using Qwen, GRPO, and AFlow**

[⬆ Back to Top](#llm-as-judge-reinforcement-learning-workflow-optimization)

</div>
