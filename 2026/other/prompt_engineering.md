# Prompt

A  prompt is the input text or query provided to an AI model, such as a large language model to generate a response.

## Prompt structure

there are three primary way to structure the prompts

### Direct instructions
**Direct instructions**: are clear and specific commands that tell the AI exactly what to do. These prompts are ideal for straightforward tasks where the user has a clear expectation of the output.

The more detailed the instruction, the more likely the output will meet expectations.

Example:

```text
Write a poem about nature.
```

### Open-ender instructions
**Open-ended instructions** are less restrictive and encourage the AI to explore broader ideas or provide creative and interpretive responses.

Example:

```text
Tell me about the universe.
```

Here, the AI has the freedom to decide what aspects of the universe to discuss, such as its origin, structure or scientific theories.

### Task-specific instructions
**Task-specific instructions** are designed for precise, goal-oriented tasks, such as translations, summarization or calculations.

Example

```
Translate this text into French: ‘Hello.’
```

根据[IBM的文章](https://www.ibm.com/think/topics/prompt-engineering-techniques)还有很多分类，下面只介绍个人认为有用的

### Few-shot prompting

少样本提示法在提示中包含少量示例，以向模型演示任务。这种方法有助于模型更好地理解上下文和预期输出。

```text
Here are some examples of how to explain complex topics:
- Topic: Photosynthesis
- Explanation: Photosynthesis is the process by which plants convert sunlight, water, and carbon dioxide into energy and oxygen.
- Topic: Gravity
- Explanation: Gravity is the force that pulls objects toward each other, like how the Earth pulls us to its surface.

Now explain: Climate Change.
```

### Chain of thought (CoT) prompting

CoT 提示鼓励模型逐步推理问题，将其分解成更小的组成部分，最终得出合乎逻辑的结论。

```text
Step 1: Define what climate change is.
Step 2: Explain the causes of climate change.
Step 3: Describe its effects on the planet.

Now, follow these steps to explain climate change.
```

### Meta prompting 

Meta prompting是指让模型生成或改进自身的提示，以更好地完成任务。

```text
Create a prompt that will help you explain climate change, its causes, and its effects in simple terms
```

### ReAct

ReAct combines reasoning and acting prompts, encouraging the model to think critically and act based on its reasoning

### Reflexion 

Reflexion能使模型能够评估其先前的输出，并对其进行改进，以提高准确性或一致性。