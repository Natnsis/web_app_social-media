"use client"

import { useState, useCallback } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { ThemeToggle } from "@/components/theme-toggle"
import { useAuthStore, isTokenExpired } from "@/lib/store/auth"
import { PostCard } from "@/components/post-card"
import { useSavedPosts, useToggleLike, useToggleSave } from "@/hooks/use-posts"
import {
    Gear, Globe, ArrowRightFromBracket, Heart, File, Bookmark, Radio,
} from "nasicon-react/outline"
import { CirclePlus } from "nasicon-react/solid"
import type { Post } from "@/types"

const filterPills = ["All", "Posts", "Shorts", "Videos"]

export default function AccountPage() {
    const router = useRouter()
    const [activeFilter, setActiveFilter] = useState("All")
    const { user, logout, accessToken } = useAuthStore()
    const tokenValid = !!(accessToken && !isTokenExpired(accessToken))
    const { data, isLoading, isError, refetch } = useSavedPosts(1, 20, tokenValid)
    const toggleLike = useToggleLike()
    const toggleSave = useToggleSave()
    const [likedPosts, setLikedPosts] = useState<Set<string>>(new Set())
    const [savedPosts, setSavedPosts] = useState<Set<string>>(new Set())

    const handleLike = useCallback((id: string) => {
        const liked = likedPosts.has(id)
        setLikedPosts((prev) => {
            const next = new Set(prev)
            if (liked) next.delete(id)
            else next.add(id)
            return next
        })
        toggleLike.mutate({ id, liked })
    }, [likedPosts, toggleLike])

    const handleSave = useCallback((id: string) => {
        const saved = savedPosts.has(id)
        setSavedPosts((prev) => {
            const next = new Set(prev)
            if (saved) next.delete(id)
            else next.add(id)
            return next
        })
        toggleSave.mutate({ id, saved })
    }, [savedPosts, toggleSave])

    const posts = data?.data ?? []

    return (
        <div className="relative flex h-full flex-col overflow-hidden">
            {/* Header */}
            <header className="flex shrink-0 items-center justify-end px-4 py-2">
                <div className="flex items-center gap-1">
                    <ThemeToggle />
                    <Link href="/account/settings">
                        <Button variant="ghost" size="icon-sm" aria-label="Settings">
                            <Gear size={20} />
                        </Button>
                    </Link>
                    <Button variant="ghost" size="icon-sm" aria-label="Logout"
                        onClick={() => { logout(); router.push("/login") }}>
                        <ArrowRightFromBracket size={18} className="text-destructive" />
                    </Button>
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
                <Tabs defaultValue="Posts">
                    <TabsList className="flex w-full bg-transparent border-b border-border rounded-none px-4 h-auto pb-0 gap-0">
                        {[
                            { value: "Posts", icon: File },
                            { value: "Saved", icon: Bookmark },
                            { value: "Liked", icon: Heart },
                            { value: "Channels", icon: Radio },
                        ].map(({ value: tab, icon: Icon }) => (
                            <TabsTrigger key={tab} value={tab}
                                className="flex-1 rounded-none border-b-2 border-transparent pb-2.5 pt-1 text-sm font-semibold data-active:border-primary data-active:text-primary data-active:bg-transparent">
                                <Icon size={15} className="sm:mr-1.5" />
                                <span className="hidden sm:inline">{tab}</span>
                            </TabsTrigger>
                        ))}
                    </TabsList>

                    {["Posts", "Saved", "Liked", "Channels"].map((tab) => (
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
                                {tab === "Saved" && !tokenValid && (
                                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                                        <p className="text-sm font-semibold">Sign in to view saved posts</p>
                                        <p className="text-xs text-muted-foreground">Your saved posts will appear here once you sign in</p>
                                        <Button variant="default" size="sm" onClick={() => router.push("/login")}>Sign in</Button>
                                    </div>
                                )}

                                {tab === "Saved" && tokenValid && isLoading && (
                                    <>
                                        {[1, 2].map((i) => (
                                            <div key={i} className="rounded-2xl border border-border bg-card p-3 animate-pulse">
                                                <div className="flex items-center gap-3">
                                                    <div className="size-10 rounded-full bg-muted" />
                                                    <div className="space-y-2 flex-1">
                                                        <div className="h-4 w-36 rounded bg-muted" />
                                                        <div className="h-3 w-16 rounded bg-muted" />
                                                    </div>
                                                </div>
                                                <div className="mt-3 space-y-2">
                                                    <div className="h-3 w-full rounded bg-muted" />
                                                    <div className="h-3 w-2/3 rounded bg-muted" />
                                                </div>
                                            </div>
                                        ))}
                                    </>
                                )}

                                {tab === "Saved" && tokenValid && isError && (
                                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                                        <p className="text-sm text-muted-foreground">Failed to load saved posts</p>
                                        <Button variant="outline" size="sm" onClick={() => refetch()}>Try again</Button>
                                    </div>
                                )}

                                {tab === "Saved" && tokenValid && !isLoading && !isError && posts.length === 0 && (
                                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                                        <p className="text-sm font-semibold">No saved posts yet</p>
                                        <p className="text-xs text-muted-foreground">Posts you save will appear here</p>
                                    </div>
                                )}

                                {tab === "Saved" && tokenValid && !isLoading && !isError && posts.map((post: Post) => (
                                    <PostCard
                                        key={post.id}
                                        post={post}
                                        isLiked={likedPosts.has(post.id)}
                                        isSaved={savedPosts.has(post.id)}
                                        onLike={handleLike}
                                        onSave={handleSave}
                                    />
                                ))}

                                {tab !== "Saved" && (
                                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                                        <p className="text-sm text-muted-foreground">Coming soon</p>
                                    </div>
                                )}
                            </div>
                        </TabsContent>
                    ))}
                </Tabs>
            </div>

            {/* FAB — Church Owner only */}
            {user?.role === "Church Owner" && (
                <Link href="/account/create-post"
                    className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                    <CirclePlus size={28} />
                </Link>
            )}
        </div>
    )
}
