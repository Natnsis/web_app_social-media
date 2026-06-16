"use client"

import { useState } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { Separator } from "@/components/ui/separator"
import { ThemeToggle } from "@/components/theme-toggle"
import { useAuthStore } from "@/lib/store/auth"
import {
    Gear, ChevronDown, Globe, Heart, Bookmark, Eye,
    MessageSquare, CornerUpRight,
} from "nasicon-react/outline"
import { DotsHorizontal, CirclePlus } from "nasicon-react/solid"

const filterPills = ["All", "Posts", "Shorts", "Videos"]

const savedPosts = [
    {
        id: 1, author: "Beza International", initials: "BI", time: "1 day ago",
        text: "God is good all the time. Share your blessings this week!",
        hashtags: ["#Blessings", "#Faith"], likes: "2.4k", comments: "120", views: "8k",
    },
    {
        id: 2, author: "Grace Community", initials: "GC", time: "3 days ago",
        text: "Our charity drive raised over $50,000 for the local food bank. Thank you all!",
        hashtags: ["#Community", "#Charity"], likes: "3.1k", comments: "245", views: "15k",
    },
]

export default function AccountPage() {
    const [activeFilter, setActiveFilter] = useState("All")
    const { user } = useAuthStore()

    return (
        <div className="relative flex h-full flex-col overflow-hidden">
            {/* Header */}
            <header className="flex shrink-0 items-center justify-between px-4 py-2">
                <button className="flex items-center gap-1 text-sm font-bold">
                    {user?.name ?? "Abebe Tesfaye"}
                    <ChevronDown size={16} />
                </button>
                <div className="flex items-center gap-1">
                    <ThemeToggle />
                    <Link href="/account/settings">
                        <Button variant="ghost" size="icon-sm" aria-label="Settings">
                            <Gear size={20} />
                        </Button>
                    </Link>
                </div>
            </header>

            <div className="flex-1 overflow-y-auto pb-24">
                {/* Profile */}
                <div className="flex flex-col items-center gap-2 px-4 pt-2 pb-4">
                    <Avatar className="size-20 ring-4 ring-primary/20">
                        <AvatarFallback className="bg-primary text-primary-foreground text-2xl font-bold">
                            {user?.initials ?? "AT"}
                        </AvatarFallback>
                    </Avatar>
                    <div className="flex flex-col items-center gap-1">
                        <h2 className="text-lg font-bold">{user?.org ?? "Beza International"}</h2>
                        <div className="flex items-center gap-1 rounded-full border border-border px-3 py-1">
                            <Globe size={14} className="text-muted-foreground" />
                            <span className="text-xs font-medium text-muted-foreground">Global Ministry Hub</span>
                        </div>
                    </div>
                    {/* Owner card */}
                    <div className="mt-2 w-full rounded-2xl border border-border bg-card p-3">
                        <div className="flex items-center gap-2">
                            <Avatar size="sm">
                                <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                    {user?.initials ?? "AT"}
                                </AvatarFallback>
                            </Avatar>
                            <div className="flex-1">
                                <p className="text-sm font-semibold">{user?.name ?? "Abebe Tesfaye"}</p>
                                <p className="text-xs text-muted-foreground">{user?.role ?? "Global Administrator"}</p>
                            </div>
                            <Badge className="text-[10px]">Owner</Badge>
                        </div>
                    </div>
                </div>

                {/* Tabs */}
                <Tabs defaultValue="Saved">
                    <TabsList className="flex w-full bg-transparent border-b border-border rounded-none px-4 h-auto pb-0 gap-0">
                        {["Saved", "Liked", "Channels"].map((tab) => (
                            <TabsTrigger key={tab} value={tab}
                                className="flex-1 rounded-none border-b-2 border-transparent pb-2.5 pt-1 text-sm font-semibold data-active:border-primary data-active:text-primary data-active:bg-transparent">
                                {tab}
                            </TabsTrigger>
                        ))}
                    </TabsList>

                    {["Saved", "Liked", "Channels"].map((tab) => (
                        <TabsContent key={tab} value={tab}>
                            {/* Filter pills */}
                            <div className="flex gap-2 overflow-x-auto px-4 py-3">
                                {filterPills.map((pill) => (
                                    <button key={pill} onClick={() => setActiveFilter(pill)}
                                        className={`shrink-0 rounded-full px-4 py-1.5 text-xs font-semibold transition-colors ${activeFilter === pill ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"}`}>
                                        {pill}
                                    </button>
                                ))}
                            </div>

                            {/* Daily verse */}
                            <div className="mx-4 mb-4 overflow-hidden rounded-2xl">
                                <div className="relative min-h-[120px] bg-cover bg-center px-4 py-4" style={{ backgroundImage: "url('/background.jpg')" }}>
                                    <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-black/70 to-blue-900/60" />
                                    <div className="relative z-10 space-y-1.5">
                                        <p className="text-[10px] font-semibold tracking-widest text-blue-300">DAILY VERSE</p>
                                        <p className="text-base font-bold leading-snug text-white">&ldquo;I can do all things through Christ.&rdquo;</p>
                                        <p className="text-xs font-semibold text-blue-300">Philippians 4:13</p>
                                    </div>
                                </div>
                            </div>

                            {/* Posts */}
                            <div className="px-4 space-y-4">
                                {savedPosts.map((post) => (
                                    <div key={post.id} className="rounded-2xl border border-border bg-card p-3 shadow-sm">
                                        <div className="flex items-center justify-between">
                                            <div className="flex items-center gap-2.5">
                                                <Avatar>
                                                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">{post.initials}</AvatarFallback>
                                                </Avatar>
                                                <div>
                                                    <p className="text-sm font-semibold">{post.author}</p>
                                                    <p className="text-xs text-muted-foreground">{post.time}</p>
                                                </div>
                                            </div>
                                            <Button variant="ghost" size="icon-sm"><DotsHorizontal size={18} /></Button>
                                        </div>
                                        <p className="mt-2 text-sm leading-relaxed">{post.text}</p>
                                        <div className="mt-1.5 flex flex-wrap gap-1.5">
                                            {post.hashtags.map((tag) => (
                                                <Badge key={tag} variant="outline" className="rounded-full text-primary border-primary/30 text-[11px]">{tag}</Badge>
                                            ))}
                                        </div>
                                        <div className="mt-3 h-40 rounded-xl bg-gray-200 dark:bg-gray-700" />
                                        <div className="mt-3 flex items-center justify-between">
                                            <div className="flex items-center gap-4">
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground"><Heart size={18} /><span>{post.likes}</span></button>
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground"><MessageSquare size={18} /><span>{post.comments}</span></button>
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground"><Eye size={18} /><span>{post.views}</span></button>
                                            </div>
                                            <div className="flex items-center gap-3">
                                                <button className="text-muted-foreground"><Bookmark size={18} /></button>
                                                <button className="text-muted-foreground"><CornerUpRight size={18} /></button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </TabsContent>
                    ))}
                </Tabs>
            </div>

            {/* FAB */}
            <Link href="/account/create-post"
                className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                <CirclePlus size={28} />
            </Link>
        </div>
    )
}
