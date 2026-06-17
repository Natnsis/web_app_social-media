"use client"

import { useState } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { CirclePlus } from "nasicon-react/solid"
import { Search } from "nasicon-react/outline"
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

export default function ChatsPage() {
    const { user } = useAuthStore()
    const [tab, setTab] = useState<"direct" | "groups">("direct")
    const chats = tab === "direct" ? directChats : groupChats

    return (
        <div className="relative flex h-full flex-col overflow-hidden">
            <header className="flex shrink-0 items-center justify-between px-4 py-3">
                <h1 className="text-xl font-bold">Chat</h1>
                <div className="flex items-center gap-2">
                    <Avatar size="sm">
                        <AvatarFallback className="bg-primary text-primary-foreground text-xs">AT</AvatarFallback>
                    </Avatar>
                    <Button variant="ghost" size="icon-sm"><Search size={20} /></Button>
                </div>
            </header>

            {/* Toggle */}
            <div className="mx-4 mb-3 flex shrink-0 rounded-full bg-muted p-1">
                {(["direct", "groups"] as const).map((t) => (
                    <button key={t} onClick={() => setTab(t)}
                        className={`flex-1 rounded-full py-1.5 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground"}`}>
                        {t === "direct" ? "Direct" : "Groups"}
                    </button>
                ))}
            </div>

            <div className="flex-1 overflow-y-auto pb-20">
                {chats.map((chat) => (
                    <Link key={chat.id} href={`/chats/${chat.id}`}
                        className="flex items-center gap-3 px-4 py-3 hover:bg-muted/50 transition-colors">
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
                        <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between">
                                <p className="font-semibold text-sm truncate">{chat.name}</p>
                                <span className="text-[11px] text-muted-foreground shrink-0 ml-2">{chat.time}</span>
                            </div>
                            <div className="flex items-center justify-between mt-0.5">
                                <p className="text-xs text-muted-foreground truncate flex-1">{chat.lastMsg}</p>
                                {chat.unread > 0 && (
                                    <span className="ml-2 flex size-5 shrink-0 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                                        {chat.unread}
                                    </span>
                                )}
                            </div>
                        </div>
                    </Link>
                ))}
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
