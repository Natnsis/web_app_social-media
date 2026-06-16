"use client"

import { useState } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { ChevronLeft, CirclePlus, FaceSmile, Send, CircleInformation } from "nasicon-react/outline"

const initialMessages = [
    {
        id: 1,
        from: "them",
        text: "Praise the Lord! How are you doing today?",
        time: "9:01 AM",
    },
    {
        id: 2,
        from: "me",
        text: "Blessed! Just finished morning prayers. You?",
        time: "9:03 AM",
    },
    {
        id: 3,
        from: "them",
        text: "Same here 🙏 Are you coming to the prayer meeting tonight?",
        time: "9:05 AM",
    },
    {
        id: 4,
        from: "me",
        text: "Yes, I will be there. What time does it start?",
        time: "9:06 AM",
    },
    {
        id: 5,
        from: "them",
        text: "7 PM at the main hall. Brother Yared will be leading worship.",
        time: "9:07 AM",
    },
    {
        id: 6,
        from: "them",
        text: "See you at the prayer meeting!",
        time: "9:08 AM",
    },
]

export default function ChatConversationPage() {
    const [messages, setMessages] = useState(initialMessages)
    const [input, setInput] = useState("")

    function sendMessage() {
        if (!input.trim()) return
        setMessages((prev) => [
            ...prev,
            {
                id: prev.length + 1,
                from: "me",
                text: input.trim(),
                time: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
            },
        ])
        setInput("")
    }

    function handleKey(e: React.KeyboardEvent<HTMLInputElement>) {
        if (e.key === "Enter") sendMessage()
    }

    return (
        <div className="flex h-full flex-col overflow-hidden">
            {/* Header */}
            <header className="flex shrink-0 items-center gap-2 border-b border-border px-2 py-2">
                <Link href="/chats" className="p-1 text-foreground">
                    <ChevronLeft size={22} />
                </Link>
                <Avatar>
                    <AvatarFallback className="bg-primary/20 text-primary font-semibold text-xs">BD</AvatarFallback>
                </Avatar>
                <div className="flex-1">
                    <p className="text-sm font-semibold leading-tight">Brother Dawit</p>
                    <div className="flex items-center gap-1">
                        <div className="size-1.5 rounded-full bg-green-500" />
                        <p className="text-[11px] text-muted-foreground">Active now</p>
                    </div>
                </div>
                <button className="flex size-7 items-center justify-center rounded-full bg-primary text-white">
                    <CircleInformation size={16} />
                </button>
            </header>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto px-3 py-4 space-y-3">
                {/* Date separator */}
                <div className="flex items-center gap-2">
                    <div className="flex-1 h-px bg-border" />
                    <span className="text-[10px] text-muted-foreground">Today</span>
                    <div className="flex-1 h-px bg-border" />
                </div>

                {messages.map((msg) => (
                    <div
                        key={msg.id}
                        className={`flex flex-col gap-0.5 ${msg.from === "me" ? "items-end" : "items-start"}`}
                    >
                        <div
                            className={`max-w-[75%] rounded-2xl px-3.5 py-2.5 text-sm leading-relaxed ${msg.from === "me"
                                    ? "rounded-br-sm bg-primary text-white"
                                    : "rounded-bl-sm bg-muted text-foreground"
                                }`}
                        >
                            {msg.text}
                        </div>
                        <span className="text-[10px] text-muted-foreground">{msg.time}</span>
                    </div>
                ))}
            </div>

            {/* Input bar */}
            <div className="flex shrink-0 items-center gap-2 border-t border-border px-3 py-2">
                <button className="text-muted-foreground">
                    <CirclePlus size={26} />
                </button>
                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={handleKey}
                    placeholder="Type a message..."
                    className="flex-1 rounded-full border border-border bg-muted px-4 py-2 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                />
                <button className="text-muted-foreground">
                    <FaceSmile size={22} />
                </button>
                <button
                    onClick={sendMessage}
                    className="flex size-9 items-center justify-center rounded-full bg-primary text-white"
                >
                    <Send size={16} />
                </button>
            </div>
        </div>
    )
}
