import React, { useState, useRef, useEffect } from 'react';
import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';
import './App.css';

function App() {
  const [connected, setConnected] = useState(false);
  const [username, setUsername] = useState('');
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState([]);
  const [isConnecting, setIsConnecting] = useState(false);
  const stompClient = useRef(null);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const connect = async (e) => {
    e.preventDefault();

    if (!username.trim()) return;

    setIsConnecting(true);
    const socket = new SockJS('http://122.51.93.212:7598/ws');
    stompClient.current = new Client({
      webSocketFactory: () => socket,
      onConnect: () => {
        setConnected(true);
        setIsConnecting(false);

        // Subscribe to the Public Topic
        stompClient.current.subscribe('/topic/public', onMessageReceived);

        // Tell your username to the server
        stompClient.current.publish({
          destination: '/app/chat.addUser',
          body: JSON.stringify({
            sender: username,
            type: 'JOIN'
          })
        });
      },
      onDisconnect: () => {
        setConnected(false);
      },
      onError: () => {
        setIsConnecting(false);
      }
    });

    stompClient.current.activate();
  };

  const onMessageReceived = (payload) => {
    const message = JSON.parse(payload.body);
    let newMessage = { ...message, id: Date.now() };

    if (message.type === 'JOIN') {
      newMessage.content = `${message.sender} 加入了聊天室!`;
    } else if (message.type === 'LEAVE') {
      newMessage.content = `${message.sender} 离开了聊天室!`;
    }

    setMessages(prev => [...prev, newMessage]);
  };

  const sendMessage = (e) => {
    e.preventDefault();

    if (!message.trim() || !stompClient.current) return;

    stompClient.current.publish({
      destination: '/app/chat.sendMessage',
      body: JSON.stringify({
        sender: username,
        content: message,
        type: 'CHAT'
      })
    });

    setMessage('');
  };

  if (!connected) {
    return (
      <div className="login-container">
        <div className="login-box">
          <h1>聊天室</h1>
          <form onSubmit={connect}>
            <input
              type="text"
              placeholder="输入用户名"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              disabled={isConnecting}
            />
            <button type="submit" disabled={isConnecting}>
              {isConnecting ? '连接中...' : '开始聊天'}
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="chat-container">
      <div className="chat-header">
        <h2>聊天室</h2>
      </div>
      <div className="messages-container">
        {messages.map(msg => (
          <div
            key={msg.id}
            className={`message ${msg.type === 'JOIN' || msg.type === 'LEAVE'
              ? 'event'
              : msg.sender === username
                ? 'own'
                : 'other'}`}
          >
            {msg.type === 'CHAT' && <span className="sender">{msg.sender}</span>}
            <p className="content">{msg.content}</p>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      <form onSubmit={sendMessage} className="message-form">
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="输入消息..."
        />
        <button type="submit">发送</button>
      </form>
    </div>
  );
}

export default App;