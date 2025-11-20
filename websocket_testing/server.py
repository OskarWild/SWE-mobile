# server.py
import asyncio
import websockets
import json
from datetime import datetime, timedelta
import random
import sys

connected_clients = set()

# Mock data for dialogues
MOCK_DIALOGUES = [
    {
        'id': '1',
        'contactName': 'John Doe',
        'lastMessage': 'Hey, are you free for lunch?',
        'timestamp': (datetime.now() - timedelta(minutes=5)).isoformat(),
        'unreadCount': 2,
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'isOnline': True
    },
    {
        'id': '2',
        'contactName': 'Sarah Smith',
        'lastMessage': 'Thanks for the help!',
        'timestamp': (datetime.now() - timedelta(hours=1)).isoformat(),
        'unreadCount': 0,
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'isOnline': True
    },
    {
        'id': '3',
        'contactName': 'Mike Johnson',
        'lastMessage': 'See you tomorrow 👋',
        'timestamp': (datetime.now() - timedelta(hours=3)).isoformat(),
        'unreadCount': 1,
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'isOnline': False
    },
    {
        'id': '4',
        'contactName': 'Emily Brown',
        'lastMessage': 'The project looks great!',
        'timestamp': (datetime.now() - timedelta(days=1)).isoformat(),
        'unreadCount': 0,
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
        'isOnline': False
    },
    {
        'id': '5',
        'contactName': 'Alex Wilson',
        'lastMessage': 'Can you send me the files?',
        'timestamp': (datetime.now() - timedelta(days=2)).isoformat(),
        'unreadCount': 5,
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
        'isOnline': True
    }
]

# Mock messages for each dialogue
MOCK_MESSAGES = {
    '1': [
        {
            'id': 'msg_1_1',
            'dialogueId': '1',
            'text': 'Hello! How are you?',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(hours=2)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_1_2',
            'dialogueId': '1',
            'text': 'Hi! I\'m doing great, thanks for asking!',
            'isMe': True,
            'timestamp': (datetime.now() - timedelta(hours=2, minutes=-5)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_1_3',
            'dialogueId': '1',
            'text': 'Hey, are you free for lunch?',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(minutes=5)).isoformat(),
            'isDelivered': True,
            'isRead': False,
        },
    ],
    '2': [
        {
            'id': 'msg_2_1',
            'dialogueId': '2',
            'text': 'Can you help me with the project?',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(hours=3)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_2_2',
            'dialogueId': '2',
            'text': 'Sure! What do you need help with?',
            'isMe': True,
            'timestamp': (datetime.now() - timedelta(hours=2)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_2_3',
            'dialogueId': '2',
            'text': 'Thanks for the help!',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(hours=1)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
    ],
    '3': [
        {
            'id': 'msg_3_1',
            'dialogueId': '3',
            'text': 'Don\'t forget about the meeting tomorrow',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(hours=4)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_3_2',
            'dialogueId': '3',
            'text': 'Thanks for reminding me! What time?',
            'isMe': True,
            'timestamp': (datetime.now() - timedelta(hours=3, minutes=-30)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_3_3',
            'dialogueId': '3',
            'text': 'See you tomorrow 👋',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(hours=3)).isoformat(),
            'isDelivered': True,
            'isRead': False,
        },
    ],
    '4': [
        {
            'id': 'msg_4_1',
            'dialogueId': '4',
            'text': 'I reviewed your work',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(days=1, hours=2)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
        {
            'id': 'msg_4_2',
            'dialogueId': '4',
            'text': 'The project looks great!',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(days=1)).isoformat(),
            'isDelivered': True,
            'isRead': True,
        },
    ],
    '5': [
        {
            'id': 'msg_5_1',
            'dialogueId': '5',
            'text': 'Can you send me the files?',
            'isMe': False,
            'timestamp': (datetime.now() - timedelta(days=2)).isoformat(),
            'isDelivered': True,
            'isRead': False,
        },
    ],
}

# Store dialogues and messages in memory
dialogues = {d['id']: d for d in MOCK_DIALOGUES}
messages = {k: list(v) for k, v in MOCK_MESSAGES.items()}  # Deep copy
message_counter = 100  # For generating new message IDs

async def send_message(websocket, message_type, data):
    """Helper to send formatted messages"""
    message = {'type': message_type, **data}
    await websocket.send(json.dumps(message))
    print(f"📤 Sent: {message_type}")

async def broadcast_to_all(message_type, data):
    """Broadcast message to all connected clients"""
    if connected_clients:
        await asyncio.gather(
            *[send_message(client, message_type, data) for client in connected_clients],
            return_exceptions=True
        )

async def handle_client(websocket):
    """Handle individual client connection"""
    connected_clients.add(websocket)
    print(f"✅ Client connected. Total clients: {len(connected_clients)}")

    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                message_type = data.get('type')
                print(f"📥 Received: {message_type}")

                if message_type == 'get_dialogues':
                    await send_message(websocket, 'initial_dialogues', {
                        'dialogues': list(dialogues.values())
                    })

                elif message_type == 'get_messages':
                    dialogue_id = data.get('dialogueId')
                    if dialogue_id in messages:
                        await send_message(websocket, 'message_history', {
                            'dialogueId': dialogue_id,
                            'messages': messages[dialogue_id]
                        })
                        print(f"📨 Sent {len(messages[dialogue_id])} messages for dialogue {dialogue_id}")
                    else:
                        # Send empty message history for new dialogues
                        await send_message(websocket, 'message_history', {
                            'dialogueId': dialogue_id,
                            'messages': []
                        })
                        print(f"📭 No messages found for dialogue {dialogue_id}")

                elif message_type == 'send_message':
                    global message_counter
                    dialogue_id = data.get('dialogueId')
                    text = data.get('text', '')
                    temp_id = data.get('tempId')

                    if dialogue_id and text:
                        message_counter += 1
                        new_message_id = f"msg_{dialogue_id}_{message_counter}"
                        timestamp = datetime.now().isoformat()

                        # Create new message
                        new_message = {
                            'id': new_message_id,
                            'dialogueId': dialogue_id,
                            'text': text,
                            'isMe': True,
                            'timestamp': timestamp,
                            'isDelivered': True,
                            'isRead': False,
                        }

                        # Store message
                        if dialogue_id not in messages:
                            messages[dialogue_id] = []
                        messages[dialogue_id].append(new_message)

                        # Update dialogue last message
                        if dialogue_id in dialogues:
                            dialogues[dialogue_id]['lastMessage'] = text
                            dialogues[dialogue_id]['timestamp'] = timestamp

                        # Send confirmation to sender
                        await send_message(websocket, 'message_sent', {
                            'dialogueId': dialogue_id,
                            'messageId': new_message_id,
                            'tempId': temp_id,
                            'timestamp': timestamp,
                        })

                        # Broadcast to all clients as incoming message
                        await broadcast_to_all('new_message', new_message)

                        # Update dialogue for all clients
                        await broadcast_to_all('dialogue_updated', {
                            'dialogue': dialogues[dialogue_id]
                        })

                        print(f"💬 Message sent in dialogue {dialogue_id}: {text}")

                elif message_type == 'ping':
                    await send_message(websocket, 'pong', {})

                elif message_type == 'mark_read':
                    dialogue_id = data.get('dialogueId')
                    if dialogue_id in dialogues:
                        dialogues[dialogue_id]['unreadCount'] = 0
                        await send_message(websocket, 'mark_read_success', {
                            'dialogueId': dialogue_id
                        })

                        # Mark all messages in this dialogue as read
                        if dialogue_id in messages:
                            for msg in messages[dialogue_id]:
                                if not msg['isMe']:
                                    msg['isRead'] = True

                elif message_type == 'create_dialogue':
                    contact_name = data.get('contactName', 'New Contact')
                    new_id = str(len(dialogues) + 1)
                    new_dialogue = {
                        'id': new_id,
                        'contactName': contact_name,
                        'lastMessage': 'New conversation started',
                        'timestamp': datetime.now().isoformat(),
                        'unreadCount': 0,
                        'avatarUrl': f'https://i.pravatar.cc/150?img={random.randint(10, 70)}',
                        'isOnline': True
                    }
                    dialogues[new_id] = new_dialogue
                    messages[new_id] = []  # Initialize empty message list

                    await broadcast_to_all('new_dialogue', {'dialogue': new_dialogue})

                else:
                    print(f"❓ Unknown message type: {message_type}")

            except json.JSONDecodeError:
                print("⚠️  Invalid JSON received")
                await send_message(websocket, 'error', {
                    'message': 'Invalid JSON format'
                })
            except Exception as e:
                print(f"❌ Error handling message: {e}")
                import traceback
                traceback.print_exc()
                await send_message(websocket, 'error', {
                    'message': str(e)
                })

    except websockets.exceptions.ConnectionClosed:
        print("🔌 Client disconnected")
    finally:
        connected_clients.remove(websocket)
        print(f"👋 Client removed. Total clients: {len(connected_clients)}")

async def handle_console_input():
    """Handle console input for manual message sending"""
    print("\n" + "=" * 60)
    print("📝 CONSOLE COMMANDS:")
    print("=" * 60)
    print("list            - Show all dialogues")
    print("<id> <message>  - Send message (e.g., '1 Hello there!')")
    print("msgs <id>       - Show messages for dialogue (e.g., 'msgs 1')")
    print("online <id>     - Set user online (e.g., 'online 1')")
    print("offline <id>    - Set user offline (e.g., 'offline 1')")
    print("quit            - Stop server")
    print("=" * 60 + "\n")

    loop = asyncio.get_event_loop()

    while True:
        user_input = await loop.run_in_executor(None, sys.stdin.readline)
        user_input = user_input.strip()

        if not user_input:
            continue

        if user_input.lower() == 'quit':
            print("🛑 Shutting down server...")
            for task in asyncio.all_tasks():
                task.cancel()
            break

        elif user_input.lower() == 'list':
            print("\n📋 Current Dialogues:")
            print("-" * 60)
            for dialogue in dialogues.values():
                status = "🟢" if dialogue['isOnline'] else "⚫"
                unread = f"({dialogue['unreadCount']} unread)" if dialogue['unreadCount'] > 0 else ""
                msg_count = len(messages.get(dialogue['id'], []))
                print(f"{status} ID: {dialogue['id']} | {dialogue['contactName']} {unread} | {msg_count} messages")
                print(f"   Last: {dialogue['lastMessage']}")
            print("-" * 60 + "\n")

        elif user_input.lower().startswith('msgs '):
            try:
                dialogue_id = user_input.split()[1]
                if dialogue_id in messages:
                    print(f"\n💬 Messages for dialogue {dialogue_id} ({dialogues[dialogue_id]['contactName']}):")
                    print("-" * 60)
                    for msg in messages[dialogue_id]:
                        sender = "You" if msg['isMe'] else dialogues[dialogue_id]['contactName']
                        status = "✓✓" if msg['isRead'] else "✓" if msg['isDelivered'] else "○"
                        print(f"[{msg['timestamp'][:19]}] {sender}: {msg['text']} {status}")
                    print("-" * 60 + "\n")
                else:
                    print(f"❌ No messages found for dialogue ID '{dialogue_id}'")
            except IndexError:
                print("⚠️  Usage: msgs <id>")

        elif user_input.lower().startswith('online '):
            try:
                dialogue_id = user_input.split()[1]
                if dialogue_id in dialogues:
                    dialogues[dialogue_id]['isOnline'] = True
                    await broadcast_to_all('user_online', {'dialogueId': dialogue_id})
                    print(f"✅ {dialogues[dialogue_id]['contactName']} is now ONLINE")
                else:
                    print(f"❌ Dialogue ID '{dialogue_id}' not found")
            except IndexError:
                print("⚠️  Usage: online <id>")

        elif user_input.lower().startswith('offline '):
            try:
                dialogue_id = user_input.split()[1]
                if dialogue_id in dialogues:
                    dialogues[dialogue_id]['isOnline'] = False
                    await broadcast_to_all('user_offline', {'dialogueId': dialogue_id})
                    print(f"✅ {dialogues[dialogue_id]['contactName']} is now OFFLINE")
                else:
                    print(f"❌ Dialogue ID '{dialogue_id}' not found")
            except IndexError:
                print("⚠️  Usage: offline <id>")

        else:
            # Try to parse as message: "<id> <message>"
            parts = user_input.split(' ', 1)
            if len(parts) == 2:
                dialogue_id, message_text = parts

                if dialogue_id in dialogues:
                    global message_counter
                    message_counter += 1
                    timestamp = datetime.now().isoformat()
                    new_message_id = f"msg_{dialogue_id}_{message_counter}"

                    # Create and store message
                    new_message = {
                        'id': new_message_id,
                        'dialogueId': dialogue_id,
                        'text': message_text,
                        'isMe': False,
                        'timestamp': timestamp,
                        'isDelivered': True,
                        'isRead': False,
                    }

                    if dialogue_id not in messages:
                        messages[dialogue_id] = []
                    messages[dialogue_id].append(new_message)

                    # Update dialogue
                    dialogues[dialogue_id]['lastMessage'] = message_text
                    dialogues[dialogue_id]['timestamp'] = timestamp
                    dialogues[dialogue_id]['unreadCount'] += 1

                    # Broadcast to all clients
                    await broadcast_to_all('new_message', new_message)
                    await broadcast_to_all('dialogue_updated', {
                        'dialogue': dialogues[dialogue_id]
                    })

                    print(f"✅ Sent to {dialogues[dialogue_id]['contactName']}: {message_text}")
                else:
                    print(f"❌ Dialogue ID '{dialogue_id}' not found. Type 'list' to see all IDs.")
            else:
                print("⚠️  Invalid command. Use: <id> <message>  (e.g., '1 Hello!')")

async def simulate_activity():
    """Simulate random chat activity for testing (optional)"""
    await asyncio.sleep(30)

    while True:
        await asyncio.sleep(random.randint(60, 120))

        if not connected_clients:
            continue

        dialogue_id = random.choice(list(dialogues.keys()))

        messages_list = [
            "👋 Auto-message: Just checking in!",
            "🤖 Auto-message: How's it going?",
            "⏰ Auto-message: Don't forget our meeting!",
        ]

        global message_counter
        message_counter += 1
        timestamp = datetime.now().isoformat()
        new_message_id = f"msg_{dialogue_id}_{message_counter}"

        new_message = {
            'id': new_message_id,
            'dialogueId': dialogue_id,
            'text': random.choice(messages_list),
            'isMe': False,
            'timestamp': timestamp,
            'isDelivered': True,
            'isRead': False,
        }

        if dialogue_id not in messages:
            messages[dialogue_id] = []
        messages[dialogue_id].append(new_message)

        dialogues[dialogue_id]['lastMessage'] = new_message['text']
        dialogues[dialogue_id]['timestamp'] = timestamp
        dialogues[dialogue_id]['unreadCount'] += 1

        await broadcast_to_all('new_message', new_message)
        await broadcast_to_all('dialogue_updated', {
            'dialogue': dialogues[dialogue_id]
        })

async def main():
    """Start WebSocket server"""
    print("\n" + "=" * 60)
    print("🚀 WebSocket Chat Server Starting...")
    print("=" * 60)

    server = await websockets.serve(handle_client, "0.0.0.0", 8080)

    print("✅ Server: ws://localhost:8080")
    print("📱 Android Emulator: ws://10.0.2.2:8080")
    print("🌐 Local Network: ws://<your-ip>:8080")

    asyncio.create_task(handle_console_input())

    # Uncomment to enable auto-messages
    # asyncio.create_task(simulate_activity())

    await asyncio.Future()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n👋 Server stopped by user")