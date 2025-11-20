#!/bin/bash
# 自动化安全清理脚本 - 为GitHub准备代码
# 此脚本会创建清理后的副本，不修改原始文件

set -e

echo "🔒 开始安全清理流程..."
echo ""

# 创建输出目录
OUTPUT_DIR="github_ready_version"
mkdir -p "$OUTPUT_DIR/src"
mkdir -p "$OUTPUT_DIR/config"
mkdir -p "$OUTPUT_DIR/scripts"

echo "📁 已创建输出目录: $OUTPUT_DIR"
echo ""

# ============================================
# 步骤 1: 清理配置文件
# ============================================
echo "🧹 步骤 1: 清理配置文件中的敏感信息..."

# 清理 aflow_llm.yaml
if [ -f "config/aflow_llm.yaml" ]; then
    cat config/aflow_llm.yaml | \
        sed 's|/home/yijia/[^"]*|\${GPT_OSS_MODEL_PATH}|g' | \
        sed 's|sk-proj-[A-Za-z0-9_-]*|\${OPENAI_API_KEY}|g' | \
        sed 's|sk-[A-Za-z0-9_-]*|\${OPENAI_API_KEY}|g' | \
        sed 's|api_key: "sk-dummy"|api_key: "\${OPENAI_API_KEY}"|' | \
        sed 's|base_url: "http://localhost:8002/v1"|base_url: "\${OPENAI_BASE_URL}"|' \
        > "$OUTPUT_DIR/config/aflow_llm.yaml.example"
    echo "  ✓ config/aflow_llm.yaml → $OUTPUT_DIR/config/aflow_llm.yaml.example"
fi

# 清理 training.yaml
if [ -f "config/training.yaml" ]; then
    cat config/training.yaml | \
        sed 's|/home/yijia/[^"]*|\${QWEN_MODEL_PATH}|g' | \
        sed 's|model_name: ".*Qwen.*"|model_name: "\${QWEN_MODEL_PATH}"|' | \
        sed 's|protected_pids: \[[0-9, ]*\]|protected_pids: []|' \
        > "$OUTPUT_DIR/config/training.yaml.example"
    echo "  ✓ config/training.yaml → $OUTPUT_DIR/config/training.yaml.example"
fi

echo ""

# ============================================
# 步骤 2: 清理Python源码中的硬编码
# ============================================
echo "🧹 步骤 2: 清理Python源码中的硬编码路径和密钥..."

for file in src/*.py; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        cat "$file" | \
            sed 's|/home/yijia/\.claude/11/AFlow|os.getenv("AFLOW_PATH", "./AFlow")|g' | \
            sed 's|/home/yijia/\.claude/11/integrated_aflow_roll|os.path.dirname(os.path.dirname(os.path.abspath(__file__)))|g' | \
            sed 's|/home/yijia/lhy/openai/gpt-oss-120b|os.getenv("GPT_OSS_MODEL_PATH", "/path/to/gpt-oss-120b")|g' | \
            sed "s|wandb_api_key = wandb_config.get('api_key', 'b42ca0000cf06f97b05eba34f58823ad5f3122a4')|wandb_api_key = wandb_config.get('api_key', os.getenv('WANDB_API_KEY'))|" | \
            sed "s|'b42ca0000cf06f97b05eba34f58823ad5f3122a4'|os.getenv('WANDB_API_KEY')|g" \
            > "$OUTPUT_DIR/src/$filename"
        echo "  ✓ src/$filename"
    fi
done

echo ""

# ============================================
# 步骤 3: 复制测试文件（清理路径）
# ============================================
echo "🧹 步骤 3: 清理测试文件..."

for file in test*.py; do
    if [ -f "$file" ]; then
        cat "$file" | \
            sed 's|/home/yijia/[^"]*AFlow|os.getenv("AFLOW_PATH", "./AFlow")|g' | \
            sed 's|/home/yijia/[^"]*|./|g' \
            > "$OUTPUT_DIR/$file"
        echo "  ✓ $file"
    fi
done

echo ""

# ============================================
# 步骤 4: 复制文档（已经是安全的）
# ============================================
echo "📄 步骤 4: 复制文档..."

cp README_GITHUB.md "$OUTPUT_DIR/README.md" 2>/dev/null || echo "  ⚠ README_GITHUB.md not found"
cp CONTRIBUTING_GITHUB.md "$OUTPUT_DIR/CONTRIBUTING.md" 2>/dev/null || echo "  ⚠ CONTRIBUTING_GITHUB.md not found"
cp INSTALLATION_GITHUB.md "$OUTPUT_DIR/INSTALLATION.md" 2>/dev/null || echo "  ⚠ INSTALLATION_GITHUB.md not found"
cp LICENSE "$OUTPUT_DIR/LICENSE" 2>/dev/null || echo "  ⚠ LICENSE not found (consider adding one)"

echo "  ✓ 文档已复制"
echo ""

# ============================================
# 步骤 5: 创建 .gitignore
# ============================================
echo "📝 步骤 5: 创建 .gitignore..."

cat > "$OUTPUT_DIR/.gitignore" << 'EOF'
# Secrets and sensitive files
.env
*.key
*.pem
config/aflow_llm.yaml
!config/aflow_llm.yaml.example
config/training.yaml
!config/training.yaml.example

# Large data files
*.jsonl
!data/sample*.jsonl
data/
!data/.gitkeep
checkpoints/
models/
!models/.gitkeep

# Logs and temporary files
logs/
wandb/
nohup.out
*.log

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Jupyter Notebook
.ipynb_checkpoints

# Virtual environments
venv/
ENV/
env/
.venv

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

echo "  ✓ .gitignore 已创建"
echo ""

# ============================================
# 步骤 6: 复制其他必要文件
# ============================================
echo "📦 步骤 6: 复制其他必要文件..."

cp requirements.txt "$OUTPUT_DIR/requirements.txt" 2>/dev/null || echo "  ⚠ requirements.txt not found"
cp train.py "$OUTPUT_DIR/train.py" 2>/dev/null && \
    sed -i 's|/home/yijia/[^"]*|./|g' "$OUTPUT_DIR/train.py" && \
    echo "  ✓ train.py"

echo ""

# ============================================
# 步骤 7: 创建占位符目录
# ============================================
echo "📂 步骤 7: 创建必要的目录结构..."

mkdir -p "$OUTPUT_DIR/data"
mkdir -p "$OUTPUT_DIR/logs"
mkdir -p "$OUTPUT_DIR/checkpoints"
mkdir -p "$OUTPUT_DIR/models"

touch "$OUTPUT_DIR/data/.gitkeep"
touch "$OUTPUT_DIR/models/.gitkeep"

echo "  ✓ 目录结构已创建"
echo ""

# ============================================
# 步骤 8: 生成验证报告
# ============================================
echo "🔍 步骤 8: 生成验证报告..."

REPORT_FILE="$OUTPUT_DIR/SECURITY_CLEANUP_REPORT.txt"

cat > "$REPORT_FILE" << EOF
安全清理验证报告
生成时间: $(date)

========================================
清理内容摘要
========================================

1. 移除的敏感信息:
   - OpenAI API密钥 (sk-proj-...)
   - Wandb API密钥 (b42ca0...)
   - 用户路径 (/home/yijia/)
   - 受保护进程ID

2. 替换为环境变量:
   - OPENAI_API_KEY
   - WANDB_API_KEY
   - QWEN_MODEL_PATH
   - GPT_OSS_MODEL_PATH
   - AFLOW_PATH

3. 清理的文件数量:
   - 配置文件: $(find $OUTPUT_DIR/config -type f 2>/dev/null | wc -l)
   - Python源码: $(find $OUTPUT_DIR/src -type f -name '*.py' 2>/dev/null | wc -l)
   - 测试文件: $(find $OUTPUT_DIR -maxdepth 1 -type f -name 'test*.py' 2>/dev/null | wc -l)

4. 验证检查:
EOF

# 验证检查
echo "" >> "$REPORT_FILE"
echo "检查残留的敏感信息..." >> "$REPORT_FILE"

if grep -r "sk-proj-" "$OUTPUT_DIR" 2>/dev/null | grep -v "REPORT" > /dev/null; then
    echo "   ❌ 发现OpenAI密钥残留" >> "$REPORT_FILE"
else
    echo "   ✓ 未发现OpenAI密钥" >> "$REPORT_FILE"
fi

if grep -r "b42ca0000cf06f97b05eba34f58823ad5f3122a4" "$OUTPUT_DIR" 2>/dev/null | grep -v "REPORT" > /dev/null; then
    echo "   ❌ 发现Wandb密钥残留" >> "$REPORT_FILE"
else
    echo "   ✓ 未发现Wandb密钥" >> "$REPORT_FILE"
fi

if grep -r "/home/yijia/" "$OUTPUT_DIR" 2>/dev/null | grep -v "REPORT" > /dev/null; then
    echo "   ⚠️ 发现硬编码路径残留" >> "$REPORT_FILE"
else
    echo "   ✓ 未发现硬编码路径" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

========================================
下一步操作
========================================

1. 审查清理结果:
   cd $OUTPUT_DIR

2. 初始化Git仓库:
   git init
   git add .
   git commit -m "Initial commit"

3. 连接到GitHub:
   git remote add origin https://github.com/beita6969/llm-as-judge.git
   git branch -M main
   git push -u origin main

4. 设置环境变量:
   cp .env.example .env
   # 编辑 .env 填入真实值

========================================
EOF

echo "  ✓ 验证报告已生成: $REPORT_FILE"
echo ""

# ============================================
# 完成
# ============================================
echo "✅ 安全清理完成！"
echo ""
echo "📊 清理统计:"
echo "   - 配置文件: $(find $OUTPUT_DIR/config -type f 2>/dev/null | wc -l)"
echo "   - Python文件: $(find $OUTPUT_DIR -type f -name '*.py' 2>/dev/null | wc -l)"
echo "   - 文档文件: $(find $OUTPUT_DIR -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l)"
echo ""
echo "📁 输出目录: $OUTPUT_DIR"
echo "📄 验证报告: $REPORT_FILE"
echo ""
echo "⚠️  重要提醒:"
echo "   1. 请审查 $OUTPUT_DIR 中的所有文件"
echo "   2. 确认没有敏感信息残留"
echo "   3. 测试清理后的代码是否可运行"
echo "   4. 在新的私有仓库中测试后再公开"
echo ""
