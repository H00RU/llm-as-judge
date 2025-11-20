#!/usr/bin/env python3
"""
训练入口 - 启动GRPO训练
支持多模型和设备配置
"""
import sys
import os
import asyncio
import argparse
import yaml

# 添加src到路径
sys.path.insert(0, 'src')

from grpo_trainer import GRPOTrainer


async def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="AFlow + ROLL GRPO训练")
    parser.add_argument(
        '--config',
        type=str,
        default='config/training.yaml',
        help='训练配置文件路径'
    )
    parser.add_argument(
        '--model',
        type=str,
        default=None,
        choices=['qwen25-7b', 'qwen3-8b'],
        help='模型名称 (overrides config)'
    )
    parser.add_argument(
        '--device',
        type=str,
        default=None,
        help='使用的GPU设备，如 cuda:0 (overrides config)'
    )
    parser.add_argument(
        '--output_dir',
        type=str,
        default=None,
        help='检查点输出目录 (overrides config)'
    )
    args = parser.parse_args()

    print("""
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     AFlow + ROLL 深度融合 - GRPO在线学习                    ║
║                                                              ║
║     多模型训练框架（支持Qwen2.5-7B和Qwen-3-8B）             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
    """)

    # 创建训练器
    trainer = GRPOTrainer(
        config_path=args.config,
        model_name=args.model,
        device=args.device,
        output_dir=args.output_dir
    )

    # 开始训练
    await trainer.train()


if __name__ == "__main__":
    asyncio.run(main())
