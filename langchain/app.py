import os

from flask import Flask, request, jsonify, app

from langchain_core.messages import SystemMessage, AIMessage
from langchain_community.utilities import GoogleSerperAPIWrapper
from langchain.agents import Tool, AgentType, Tool, initialize_agent
from langchain_openai import ChatOpenAI

os.environ['OPENAI_API_KEY'] = ''
os.environ['SERPER_API_KEY'] = ''

llm = ChatOpenAI(model="gpt-3.5-turbo-1106", temperature=0.3)
search = GoogleSerperAPIWrapper()
tools = [
    Tool(
        name="Intermediate Answer",
        func=search.run,
        description="useful for when you need to ask with search"
    ),
]

app = Flask(__name__)

@app.route('/answer_prompt', methods=['POST'])
def answer_prompt():
    prompt = request.json.get('prompt')
    if not prompt:
        return jsonify({'error': 'Missing prompt'}), 400

    try:
        print('Handling new request: ', prompt)
        choices = request.json.get('choices')
        if not choices:
            return jsonify({'error': 'Missing choices'}), 400
        
        # # [{'role': 'system', 'content': ['Respond to the user in pirate talk!', 'Respond to me backwards and in french.']}, {'role': 'assistant', 'content': ['The weather today in Bristol is 18c', 'Test saving content', 'Test']}]
        sys_messages = [choice for choice in choices if choice.get('role', '').lower() == 'system']
        sys_message = SystemMessage(content=" ".join([msg['content'] for msg in sys_messages]))
        print('System message included: ', sys_message.content)

        chat_history = []
        if len(sys_message.content) > 0:
            chat_history.append(sys_message)
        print('Creating agent...')

        agent_executor = initialize_agent(tools, llm, agent=AgentType.CHAT_CONVERSATIONAL_REACT_DESCRIPTION, verbose=True, handle_parsing_errors=True)
        print('Agent executor created: ', agent_executor)

        answer = agent_executor.run(input=prompt, chat_history=chat_history)
        print('Answer: ', answer)

        return jsonify({'response': answer})
    except Exception as e:
        print('Error: ', str(e))
        return jsonify({'error': str(e)}), 500
    
if __name__ == '__main__':
    app.run(port=5001)
    print('Server started on port 5001.')