"use client"

import { useState } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { CirclePlus } from "nasicon-react/solid"
import { CircleInformation, FaceSmile, Search, Send } from "nasicon-react/outline"
import { useAuthStore } from "@/lib/store/auth"

const directChats = [
    { id: "brother-dawit", name: "Brother Dawit", initials: "BD", time: "12:45 PM", lastMsg: "God bless you. See you at...", unread: 1, online: true },
    { id: "sister-sarah", name: "Sister Sarah", initials: "SS", time: "Yesterday", lastMsg: "Thank you for the prayer...", unread: 0, online: false },
    { id: "pastor-elias", name: "Pastor Elias", initials: "PE", time: "Mon", lastMsg: "The sermon notes are ready fo...", unread: 0, online: true },
    { id: "timothy", name: "Timothy", initials: "T", time: "Nov 12", lastMsg: "Can we reschedule the yout...", unread: 0, online: false },
]

const groupChats = [
    { id: "addis-youth", name: "Addis Ababa Youth ...", initials: "AY", time: "12:45 PM", lastMsg: "Selam Dawit: Looking for...", unread: 3, online: false },
    { id: "worship-bole", name: "Worship Team - Bole", initials: "WB", time: "Yesterday", lastMsg: "Meron: Practice starts at ...", unread: 12, online: false },
    { id: "faithconnect-fellowship", name: "FaithConnect Fellowship", initials: "FF", time: "Wed", lastMsg: "Marcus Aurelius: Welcome eve...", unread: 0, online: false },
]

const initialMessages = [
    { id: 1, from: "them", text: "Praise the Lord! How are you doing today?", time: "9:01 AM" },
    { id: 2, from: "me", text: "Blessed! Just finished morning prayers. You?", time: "9:03 AM" },
    { id: 3, from: "them", text: "Same here. Are you coming to the prayer meeting tonight?", time: "9:05 AM" },
    { id: 4, from: "me", text: "Yes, I will be there. What time does it start?", time: "9:06 AM" },
    { id: 5, from: "them", text: "7 PM at the main hall. Brother Yared will be leading worship.", time: "9:07 AM" },
]

type ChatItem = typeof directChats[number] | typeof groupChats[number]

function ChatListItem({
    chat,
    active,
    href,
    onSelect,
}: {
    chat: ChatItem
    active?: boolean
    href?: string
    onSelect?: () => void
}) {
    const content = (
        <>
            <div className="relative">
                <Avatar size="lg">
                    <AvatarFallback className="bg-primary/20 text-primary font-semibold text-sm">
                        {chat.initials}
                    </AvatarFallback>
                </Avatar>
                {chat.online && (
                    <div className="absolute bottom-0 right-0 size-2.5 rounded-full bg-green-500 ring-2 ring-background" />
                )}
            </div>
            <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between">
                    <p className="truncate text-sm font-semibold">{chat.name}</p>
                    <span className="ml-2 shrink-0 text-[11px] text-muted-foreground">{chat.time}</span>
                </div>
                <div className="mt-0.5 flex items-center justify-between">
                    <p className="flex-1 truncate text-xs text-muted-foreground">{chat.lastMsg}</p>
                    {chat.unread > 0 && (
                        <span className="ml-2 flex size-5 shrink-0 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                            {chat.unread}
                        </span>
                    )}
                </div>
            </div>
        </>
    )

    const className = `flex w-full items-center gap-3 px-4 py-3 text-left transition-colors ${
        active ? "bg-primary/10 text-foreground" : "hover:bg-muted/50"
    }`

    if (href) {
        return <Link href={href} className={className}>{content}</Link>
    }

    return <button type="button" onClick={onSelect} className={className}>{content}</button>
}

function DesktopConversation({ chat }: { chat: ChatItem }) {
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
        <section className="flex min-w-0 flex-1 flex-col overflow-hidden bg-background">
            <header className="flex shrink-0 items-center gap-3 border-b border-border px-5 py-4">
                <Avatar>
                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-semibold">{chat.initials}</AvatarFallback>
                </Avatar>
                <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-bold leading-tight">{chat.name}</p>
                    <div className="flex items-center gap-1.5">
                        <div className={`size-1.5 rounded-full ${chat.online ? "bg-green-500" : "bg-muted-foreground/50"}`} />
                        <p className="text-[11px] text-muted-foreground">{chat.online ? "Active now" : "Last active recently"}</p>
                    </div>
                </div>
                <button className="flex size-8 items-center justify-center rounded-xl bg-primary text-primary-foreground">
                    <CircleInformation size={16} />
                </button>
            </header>

            <div className="flex-1 space-y-3 overflow-y-auto px-6 py-5">
                <div className="flex items-center gap-2">
                    <div className="h-px flex-1 bg-border" />
                    <span className="text-[10px] text-muted-foreground">Today</span>
                    <div className="h-px flex-1 bg-border" />
                </div>

                {messages.map((msg) => (
                    <div
                        key={msg.id}
                        className={`flex flex-col gap-0.5 ${msg.from === "me" ? "items-end" : "items-start"}`}
                    >
                        <div
                            className={`max-w-[68%] rounded-2xl px-3.5 py-2.5 text-sm leading-relaxed ${
                                msg.from === "me"
                                    ? "rounded-br-md bg-primary text-primary-foreground"
                                    : "rounded-bl-md bg-muted text-foreground"
                            }`}
                        >
                            {msg.text}
                        </div>
                        <span className="text-[10px] text-muted-foreground">{msg.time}</span>
                    </div>
                ))}
            </div>

            <div className="flex shrink-0 items-center gap-2 border-t border-border px-5 py-3">
                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={handleKey}
                    placeholder="Type a message..."
                    className="h-11 flex-1 rounded-xl border border-border bg-muted px-4 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary/20"
                />
                <button className="text-muted-foreground">
                    <FaceSmile size={22} />
                </button>
                <button
                    onClick={sendMessage}
                    className="flex size-11 items-center justify-center rounded-xl bg-primary text-primary-foreground"
                >
                    <Send size={17} />
                </button>
            </div>
        </section>
    )
}

export default function ChatsPage() {
    const { user } = useAuthStore()
    const [tab, setTab] = useState<"direct" | "groups">("direct")
    const [selectedChatId, setSelectedChatId] = useState(directChats[0].id)
    const chats = tab === "direct" ? directChats : groupChats
    const selectedChat = chats.find((chat) => chat.id === selectedChatId) ?? chats[0]

    function changeTab(nextTab: "direct" | "groups") {
        setTab(nextTab)
        setSelectedChatId((nextTab === "direct" ? directChats : groupChats)[0].id)
    }

    return (
        <div className="relative flex h-full flex-col overflow-hidden">
            <header className="flex shrink-0 items-center justify-between px-4 py-3 lg:hidden">
                <h1 className="text-xl font-bold">Chat</h1>
                <div className="flex items-center gap-2">
                    <Avatar size="sm">
                        <AvatarFallback className="bg-primary text-primary-foreground text-xs">AT</AvatarFallback>
                    </Avatar>
                    <Button variant="ghost" size="icon-sm"><Search size={20} /></Button>
                </div>
            </header>

            {/* Toggle */}
            <div className="mx-4 mb-3 flex shrink-0 rounded-full bg-muted p-1 lg:hidden">
                {(["direct", "groups"] as const).map((t) => (
                    <button key={t} onClick={() => changeTab(t)}
                        className={`flex-1 rounded-full py-1.5 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground"}`}>
                        {t === "direct" ? "Direct" : "Groups"}
                    </button>
                ))}
            </div>

            <div className="flex-1 overflow-y-auto pb-20 lg:hidden">
                {chats.map((chat) => (
                    <ChatListItem key={chat.id} chat={chat} href={`/chats/${chat.id}`} />
                ))}
            </div>

            <div className="hidden h-full min-h-0 overflow-hidden rounded-2xl border border-border bg-card lg:flex">
                <aside className="flex w-86 shrink-0 flex-col border-r border-border bg-card xl:w-96">
                    <div className="border-b border-border px-4 py-4">
                        <div className="flex items-center justify-between gap-3">
                            <div>
                                <h1 className="text-xl font-black">Messages</h1>
                                <p className="text-xs text-muted-foreground">Direct and ministry group chats</p>
                            </div>
                            {user?.role === "Church Owner" && (
                                <Link href="/chats/new-group"
                                    className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground">
                                    <CirclePlus size={20} />
                                </Link>
                            )}
                        </div>

                        <div className="mt-4 flex rounded-xl bg-muted p-1">
                            {(["direct", "groups"] as const).map((t) => (
                                <button key={t} onClick={() => changeTab(t)}
                                    className={`flex-1 rounded-lg py-2 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-background text-foreground" : "text-muted-foreground hover:text-foreground"}`}>
                                    {t === "direct" ? "Direct" : "Groups"}
                                </button>
                            ))}
                        </div>

                        <div className="relative mt-3">
                            <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                            <input
                                placeholder="Search conversations"
                                className="h-10 w-full rounded-xl border border-border bg-background pl-9 pr-3 text-sm outline-none focus:border-primary"
                            />
                        </div>
                    </div>

                    <div className="flex-1 overflow-y-auto">
                        {chats.map((chat) => (
                            <ChatListItem
                                key={chat.id}
                                chat={chat}
                                active={chat.id === selectedChat.id}
                                onSelect={() => setSelectedChatId(chat.id)}
                            />
                        ))}
                    </div>
                </aside>

                <DesktopConversation chat={selectedChat} />
            </div>

            {/* FAB → new group — Church Owner only */}
            {user?.role === "Church Owner" && (
                <Link href="/chats/new-group"
                    className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                    <CirclePlus size={28} />
                </Link>
            )}
        </div>
    )
}
