"use client"

import { useEffect, useRef, useState, useCallback } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { ThemeToggle } from "@/components/theme-toggle"
import { useAuthStore } from "@/lib/store/auth"
import { PostCard } from "@/components/post-card"
import { usePosts, useToggleLike, useToggleSave } from "@/hooks/use-posts"
import { GridCircle, Bell, CirclePlus } from "nasicon-react/solid"
import {
    Heart, HouseChimneyBlank, User, Gift, Users, Globe, ChevronRight, Gear,
    Xmark, ArrowRightFromBracket, Church, CornerUpRight,
    TowerBroadcast, Video, PenSquare, CalendarAlt, LocationPin,
} from "nasicon-react/outline"
import {
    BarChart3, CalendarPlus, Clapperboard, FileText, MessageCircleWarning, Radio,
} from "lucide-react"
import type { Post } from "@/types"

const liveUsers = [
    { name: "Grace Ch...", initials: "GC", id: "grace-ch" },
    { name: "Hope Val...", initials: "HV", id: "hope-val" },
    { name: "Unity", initials: "UN", id: "unity" },
    { name: "The Well", initials: "TW", id: "the-well" },
    { name: "New Life", initials: "NL", id: "new-life" },
    { name: "Zion", initials: "ZN", id: "zion" },
]

const ownerActions = [
    { label: "Create Group", href: "/chats/new-group", Icon: Users, metric: "12 active" },
    { label: "Post Event", href: "/account/create-post", Icon: CalendarPlus, metric: "3 drafts" },
    { label: "Publish Article", href: "/account/create-post", Icon: FileText, metric: "21 reads" },
    { label: "Go Live", href: "/shorts", Icon: Radio, metric: "Prime time" },
    { label: "Upload Video", href: "/account/create-post", Icon: Clapperboard, metric: "Shorts ready" },
    { label: "Moderation", href: "/account/settings", Icon: MessageCircleWarning, metric: "4 queued" },
]

const desktopTrends = [
    { label: "Sunday Recap", value: "18.4k views" },
    { label: "Youth Worship", value: "7 live rooms" },
    { label: "Giving Campaign", value: "82% funded" },
]

const fabItems = [
    { label: "Create Group", Icon: Users, href: "/chats/new-group" },
    { label: "Create Campaign", Icon: TowerBroadcast, href: "/campaigns" },
    { label: "Start Live", Icon: Video, href: "/" },
    { label: "Create Post", Icon: PenSquare, href: "/account/create-post" },
]

const upcomingEvents = [
    { date: "NOV 12", title: "Bible Study", time: "21:00 – 9:30 PM" },
    { date: "NOV 14", title: "Youth Night", time: "11:00 – 3:00 PM" },
]

const nearbyChurches = [
    { id: "beza", name: "Beza Community Church", dist: "0.4 km", initials: "BC" },
    { id: "summit", name: "Summit Fellowship", dist: "1.3 km", initials: "SF" },
    { id: "grace", name: "Grace Chapel", dist: "2.1 km", initials: "GC" },
    { id: "hope", name: "Hope Valley Church", dist: "2.8 km", initials: "HV" },
    { id: "zion", name: "Zion Baptist", dist: "3.5 km", initials: "ZB" },
    { id: "newlife", name: "New Life Ministry", dist: "4.2 km", initials: "NL" },
]

type MenuSection = {
    title: string
    items: { label: string; icon: React.ReactNode; active?: boolean; extra?: string; href?: string }[]
}

function SideDrawer({ open, onClose }: { open: boolean; onClose: () => void }) {
    const { user, logout } = useAuthStore()
    const router = useRouter()
    const sections: MenuSection[] = [
        {
            title: "DISCOVER",
            items: [
                { label: "Home", icon: <HouseChimneyBlank size={18} />, active: true },
                { label: "Account Overview", icon: <User size={18} /> },
                { label: "Discovery", icon: <Globe size={18} /> },
            ],
        },
        {
            title: "COMMUNITY",
            items: [
                { label: "Groups", icon: <Users size={18} /> },
                { label: "Campaigns", icon: <Heart size={18} />, href: "/campaigns" },
                { label: "Gift", icon: <Gift size={18} /> },
            ],
        },
        {
            title: "PREFERENCES",
            items: [{ label: "Language", icon: <Globe size={18} />, extra: "English" }],
        },
    ]

    return (
        <>
            {open && <div className="absolute inset-0 z-40 bg-black/40" onClick={onClose} />}
            <div className={`absolute inset-y-0 left-0 z-50 flex w-72 flex-col bg-background shadow-xl transition-transform duration-300 ${open ? "translate-x-0" : "-translate-x-full"}`}>
                <div className="flex items-center justify-end px-4 pt-4">
                    <Button variant="ghost" size="icon-sm" onClick={onClose}><Xmark size={20} /></Button>
                </div>
                <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-4">
                    {sections.map((section) => (
                        <div key={section.title}>
                            <p className="mb-1 px-1 text-[10px] font-bold tracking-widest text-muted-foreground">{section.title}</p>
                            {section.items.map((item) => (
                                <button key={item.label}
                                    onClick={() => { if (item.href) router.push(item.href); onClose() }}
                                    className={`flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors ${item.active ? "bg-primary/10 font-semibold text-primary" : "hover:bg-muted"}`}>
                                    <span className={item.active ? "text-primary" : "text-muted-foreground"}>{item.icon}</span>
                                    <span className="flex-1 text-left">{item.label}</span>
                                    {item.extra && <><span className="text-xs text-muted-foreground">{item.extra}</span><ChevronRight size={14} className="text-muted-foreground" /></>}
                                </button>
                            ))}
                        </div>
                    ))}
                </div>
                <Separator />
                <div className="px-5 py-4 flex items-center justify-between">
                    <p className="text-[10px] text-muted-foreground">v2.4.0</p>
                    <button onClick={() => { logout(); router.push("/login") }}
                        className="flex items-center gap-2 text-sm font-medium text-destructive">
                        <ArrowRightFromBracket size={18} /> Logout
                    </button>
                </div>
            </div>
        </>
    )
}

/* ── Shared feed content (used on both mobile and desktop) ── */
function FeedContent() {
    const { data, isLoading, isError, refetch } = usePosts()
    const toggleLike = useToggleLike()
    const toggleSave = useToggleSave()
    const [likedPosts, setLikedPosts] = useState<Set<string>>(new Set())
    const [savedPosts, setSavedPosts] = useState<Set<string>>(new Set())
    const [followedChurches, setFollowedChurches] = useState<Set<string>>(new Set())

    const posts = data?.data ?? []
    useEffect(() => {
        setLikedPosts(new Set(posts.filter((p) => p.isLiked).map((p) => p.id)))
        setSavedPosts(new Set(posts.filter((p) => p.isSaved).map((p) => p.id)))
    }, [data])

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

    return (
        <div className="space-y-4">
            {/* Live Now */}
            <div>
                <div className="mb-2.5 flex items-center justify-between">
                    <h2 className="text-sm font-bold text-primary">Live Now</h2>
                    <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">View all</Button>
                </div>
                <div className="flex h-fit gap-4 overflow-x-auto px-1 py-1">
                    {liveUsers.map((u, i) => (
                        <Link key={i} href={`/live/${u.id}`} className="relative flex shrink-0 flex-col items-center gap-1">
                            <div className="relative">
                                <Avatar className="size-14 ring-2 ring-red-500 ring-offset-1">
                                    <AvatarFallback className="bg-muted text-xs font-medium">{u.initials}</AvatarFallback>
                                </Avatar>
                                <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 flex items-center gap-0.5 rounded-full bg-red-500 px-1.5 py-0.5">
                                    <div className="size-1 rounded-full bg-white animate-pulse" />
                                    <span className="text-[8px] font-bold text-white">LIVE</span>
                                </div>
                            </div>
                            <span className="mt-2 w-14 truncate text-center text-[10px] text-muted-foreground">{u.name}</span>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Nearby Churches */}
            <div>
                <div className="mb-2.5 flex items-center justify-between">
                    <h2 className="flex items-center gap-1.5 text-sm font-bold"><LocationPin size={15} className="text-primary" /> Nearby</h2>
                    <Link href="/nearby-churches">
                        <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">See all</Button>
                    </Link>
                </div>
                <div className="flex gap-3 overflow-x-auto px-1 py-1">
                    {nearbyChurches.map((c) => (
                        <div key={c.id} className="flex w-44 shrink-0 flex-col gap-2 rounded-xl border border-border bg-card p-3">
                            <div className="flex items-center gap-2.5">
                                <Avatar size="sm" className="shrink-0">
                                    <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-semibold">{c.initials}</AvatarFallback>
                                </Avatar>
                                <p className="truncate text-xs font-semibold">{c.name}</p>
                            </div>
                            <p className="flex items-center gap-1 text-[10px] text-muted-foreground">
                                <LocationPin size={12} className="text-primary" /> {c.dist}
                            </p>
                            <Button
                                variant="default"
                                size="xs"
                                className="w-full rounded-full text-[10px]"
                                onClick={() => {
                                    setFollowedChurches((prev) => {
                                        const next = new Set(prev)
                                        if (next.has(c.id)) next.delete(c.id)
                                        else next.add(c.id)
                                        return next
                                    })
                                }}
                            >
                                {followedChurches.has(c.id) ? "Following" : "Follow"}
                            </Button>
                        </div>
                    ))}
                </div>
            </div>

            {/* Daily Verse */}
            <div className="overflow-hidden rounded-2xl">
                <div className="relative min-h-[150px] bg-cover bg-center px-4 py-5" style={{ backgroundImage: "url('/background.jpg')" }}>
                    <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-black/70 to-blue-900/60" />
                    <div className="relative z-10 space-y-2">
                        <p className="text-[10px] font-semibold tracking-widest text-blue-300 uppercase">Daily Scripture</p>
                        <p className="text-xl font-bold leading-snug text-white">
                            &ldquo;The Lord is my light and my salvation&mdash;whom shall I fear?&rdquo;
                        </p>
                        <p className="text-sm font-semibold text-blue-300">Psalm 27:1</p>
                    </div>
                </div>
            </div>

            {/* Posts */}
            <div className="space-y-4">
                {isLoading && (
                    <>
                        {[1, 2, 3].map((i) => (
                            <div key={i} className="rounded-2xl border border-border bg-card p-4 animate-pulse">
                                <div className="flex items-center gap-3">
                                    <div className="size-11 rounded-full bg-muted" />
                                    <div className="space-y-2 flex-1">
                                        <div className="h-4 w-40 rounded bg-muted" />
                                        <div className="h-3 w-20 rounded bg-muted" />
                                    </div>
                                </div>
                                <div className="mt-4 space-y-2">
                                    <div className="h-3 w-full rounded bg-muted" />
                                    <div className="h-3 w-3/4 rounded bg-muted" />
                                </div>
                                <div className="mt-3 h-44 rounded-xl bg-muted" />
                                <div className="mt-3 flex gap-5">
                                    <div className="h-4 w-12 rounded bg-muted" />
                                    <div className="h-4 w-12 rounded bg-muted" />
                                    <div className="h-4 w-12 rounded bg-muted" />
                                </div>
                            </div>
                        ))}
                    </>
                )}

                {isError && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                        <p className="text-sm text-muted-foreground">Failed to load posts</p>
                        <Button variant="outline" size="sm" onClick={() => refetch()}>Try again</Button>
                    </div>
                )}

                {!isLoading && !isError && posts.length === 0 && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                        <p className="text-sm text-muted-foreground">No posts yet</p>
                        <Link href="/account/create-post">
                            <Button variant="outline" size="sm">Create the first post</Button>
                        </Link>
                    </div>
                )}

                {!isLoading && !isError && posts.map((post: Post) => (
                    <PostCard
                        key={post.id}
                        post={post}
                        isLiked={likedPosts.has(post.id)}
                        isSaved={savedPosts.has(post.id)}
                        onLike={handleLike}
                        onSave={handleSave}
                    />
                ))}
            </div>
        </div>
    )
}

function DesktopStoryRail() {
    return (
        <div className="flex gap-5 overflow-x-auto px-3 py-2">
            {liveUsers.map((u, i) => (
                <Link key={u.id} href={`/live/${u.id}`} className="group flex w-16 shrink-0 flex-col items-center gap-2">
                    <div className="relative">
                        <div className="absolute -inset-1 rounded-full bg-primary/25 transition-transform group-hover:scale-105" />
                        <Avatar className="relative size-14 border-2 border-background">
                            <AvatarFallback className="bg-card text-xs font-bold">{u.initials}</AvatarFallback>
                        </Avatar>
                        {i === 0 && (
                            <div className="absolute -bottom-1 -right-1 flex size-5 items-center justify-center rounded-full border-2 border-background bg-primary text-[13px] font-bold text-primary-foreground">
                                +
                            </div>
                        )}
                    </div>
                    <span className="w-full truncate text-center text-[11px] font-semibold">{i === 0 ? "You" : u.name}</span>
                </Link>
            ))}
        </div>
    )
}

function DesktopComposer({ isOwner }: { isOwner: boolean }) {
    return (
        <div className="rounded-2xl border border-border bg-card p-4">
            <div className="flex items-center gap-3">
                <div className="flex h-11 flex-1 items-center rounded-xl border border-border bg-muted/40 px-4 text-sm text-muted-foreground">
                    Share a testimony, question, update, or prayer request
                </div>
                <Button className="size-11 rounded-xl" size="icon" aria-label="Publish">
                    <CornerUpRight size={20} />
                </Button>
            </div>
            {isOwner && (
                <div className="mt-4 grid grid-cols-3 gap-2 xl:grid-cols-6">
                    {ownerActions.map(({ label, href, Icon, metric }) => (
                        <Link
                            key={label}
                            href={href}
                            className="group flex items-center gap-2 rounded-xl border border-border bg-background p-2 transition-colors hover:border-primary/40 hover:bg-primary/5"
                        >
                            <div className="flex size-7 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <Icon size={15} />
                            </div>
                            <div className="min-w-0">
                                <p className="truncate text-[11px] font-bold leading-tight">{label}</p>
                                <p className="truncate text-[10px] text-muted-foreground leading-tight">{metric}</p>
                            </div>
                        </Link>
                    ))}
                </div>
            )}
        </div>
    )
}

function DesktopFeedExperience({ isOwner }: { isOwner: boolean }) {
    const composerRef = useRef<HTMLDivElement>(null)
    const [composerHeight, setComposerHeight] = useState(0)
    const { data, isLoading, isError, refetch } = usePosts()
    const toggleLike = useToggleLike()
    const toggleSave = useToggleSave()
    const [likedPosts, setLikedPosts] = useState<Set<string>>(new Set())
    const [savedPosts, setSavedPosts] = useState<Set<string>>(new Set())

    const posts = data?.data ?? []
    useEffect(() => {
        setLikedPosts(new Set(posts.filter((p) => p.isLiked).map((p) => p.id)))
        setSavedPosts(new Set(posts.filter((p) => p.isSaved).map((p) => p.id)))
    }, [data])

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

    useEffect(() => {
        if (composerRef.current) {
            setComposerHeight(composerRef.current.offsetHeight)
        }
    }, [isOwner])

    return (
        <div className="mx-auto grid h-full max-w-[1500px] grid-cols-[minmax(0,1fr)_320px] gap-5 py-4">
            <section className="min-w-0 overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
                <div className="space-y-4 px-3 pb-10">
                    <DesktopStoryRail />
                    <div className="sticky top-0 z-10" style={{ height: composerHeight || undefined }}>
                        <div ref={composerRef}>
                            <DesktopComposer isOwner={isOwner} />
                        </div>
                    </div>

                    {isLoading && (
                        <>
                            {[1, 2, 3].map((i) => (
                                <div key={i} className="overflow-hidden rounded-2xl border border-border bg-card p-5 animate-pulse">
                                    <div className="flex items-center gap-3">
                                        <div className="size-11 rounded-full bg-muted" />
                                        <div className="space-y-2 flex-1">
                                            <div className="h-4 w-40 rounded bg-muted" />
                                            <div className="h-3 w-20 rounded bg-muted" />
                                        </div>
                                    </div>
                                    <div className="mt-4 space-y-2">
                                        <div className="h-3 w-full rounded bg-muted" />
                                        <div className="h-3 w-3/4 rounded bg-muted" />
                                    </div>
                                    <div className="mt-3 aspect-video rounded-xl bg-muted" />
                                </div>
                            ))}
                        </>
                    )}

                    {isError && (
                        <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                            <p className="text-sm text-muted-foreground">Failed to load posts</p>
                            <Button variant="outline" size="sm" onClick={() => refetch()}>Try again</Button>
                        </div>
                    )}

                    {!isLoading && !isError && posts.length === 0 && (
                        <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                            <p className="text-sm text-muted-foreground">No posts yet</p>
                            <Link href="/account/create-post">
                                <Button variant="outline" size="sm">Create the first post</Button>
                            </Link>
                        </div>
                    )}

                    {posts.length > 0 && (
                        <PostCard
                            post={posts[0]}
                            featured
                            isLiked={likedPosts.has(posts[0].id)}
                            isSaved={savedPosts.has(posts[0].id)}
                            onLike={handleLike}
                            onSave={handleSave}
                        />
                    )}
                    {posts.slice(1).map((post: Post) => (
                        <PostCard
                            key={post.id}
                            post={post}
                            isLiked={likedPosts.has(post.id)}
                            isSaved={savedPosts.has(post.id)}
                            onLike={handleLike}
                            onSave={handleSave}
                        />
                    ))}
                </div>
            </section>
            <DesktopRightPanel />
        </div>
    )
}

/* ── Desktop right panel ── */
function DesktopRightPanel() {
    return (
        <aside className="hidden h-full shrink-0 flex-col overflow-y-auto rounded-2xl border border-border bg-card p-4 xl:flex">
            <div className="rounded-xl bg-primary p-4 text-primary-foreground">
                <p className="text-xs font-bold uppercase tracking-wider text-primary-foreground/70">Creator pulse</p>
                <div className="mt-4 grid grid-cols-2 gap-3">
                    <div>
                        <p className="text-2xl font-black">24.8k</p>
                        <p className="text-[11px] text-primary-foreground/70">weekly reach</p>
                    </div>
                    <div>
                        <p className="text-2xl font-black">+18%</p>
                        <p className="text-[11px] text-primary-foreground/70">engagement</p>
                    </div>
                </div>
            </div>

            {/* Upcoming Events */}
            <div className="mt-6">
                <div className="flex items-center justify-between mb-3">
                    <p className="flex items-center gap-1.5 text-xs font-bold"><CalendarAlt size={13} className="text-primary" /> Upcoming Events</p>
                    <button className="text-[11px] text-primary hover:underline">View All</button>
                </div>
                <div className="space-y-2.5">
                    {upcomingEvents.map((ev) => (
                        <div key={ev.title} className="flex gap-3 rounded-xl border border-border bg-background p-3">
                            <div className="flex w-10 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <p className="text-[9px] font-bold uppercase leading-tight">{ev.date.split(" ")[0]}</p>
                                <p className="text-base font-bold leading-tight">{ev.date.split(" ")[1]}</p>
                            </div>
                            <div>
                                <p className="text-xs font-semibold">{ev.title}</p>
                                <p className="text-[10px] text-muted-foreground">{ev.time}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <Separator />

            <div>
                <div className="mb-3 flex items-center justify-between">
                    <p className="flex items-center gap-1.5 text-xs font-bold"><BarChart3 size={14} className="text-primary" /> Trending Now</p>
                    <button className="text-[11px] text-primary hover:underline">See all</button>
                </div>
                <div className="space-y-2">
                    {desktopTrends.map((trend) => (
                        <div key={trend.label} className="flex items-center justify-between rounded-xl bg-muted/45 px-3 py-2.5">
                            <p className="text-xs font-semibold">{trend.label}</p>
                            <p className="text-[11px] text-muted-foreground">{trend.value}</p>
                        </div>
                    ))}
                </div>
            </div>

            <Separator />

            {/* Nearby Churches */}
            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3"><LocationPin size={13} className="text-primary" /> Nearby Churches</p>
                <div className="space-y-2">
                    {nearbyChurches.map((c) => (
                        <div key={c.name} className="flex items-center gap-2.5 rounded-xl border border-border bg-background p-3">
                            <Avatar size="sm">
                                <AvatarFallback className="bg-primary/20 text-primary text-[10px]">{c.initials}</AvatarFallback>
                            </Avatar>
                            <div className="flex-1 min-w-0">
                                <p className="text-xs font-semibold truncate">{c.name}</p>
                                <p className="text-[10px] text-muted-foreground">{c.dist}</p>
                            </div>
                        </div>
                    ))}
                    <Link href="/nearby-churches">
                        <Button variant="outline" size="xs" className="w-full rounded-xl text-xs">Open Local Map</Button>
                    </Link>
                </div>
            </div>

            <Separator />

            {/* Global Impact */}
            <div>
                <p className="text-xs font-bold mb-3">Global Impact</p>
                <div className="rounded-xl border border-border bg-background p-4 space-y-2">
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Active Missions</span>
                        <span className="font-semibold text-primary">12</span>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Countries</span>
                        <span className="font-semibold">8 Countries</span>
                    </div>
                    <p className="text-[10px] text-muted-foreground leading-relaxed">
                        Your support currently funds 12 active mission outposts across Eastern Africa and Southern Asia.
                    </p>
                </div>
            </div>
        </aside>
    )
}

export default function HomePage() {
    const { user, logout } = useAuthStore()
    const router = useRouter()
    const [drawerOpen, setDrawerOpen] = useState(false)
    const [fabOpen, setFabOpen] = useState(false)
    const [profileOpen, setProfileOpen] = useState(false)

    return (
        <>
            {/* ── Desktop layout (lg+): full-width with right panel ── */}
            <div className="hidden h-full overflow-hidden bg-background lg:block">
                <DesktopFeedExperience isOwner={user?.role === "Church Owner"} />
            </div>

            {/* ── Mobile layout (< lg): phone-style ── */}
            <div className="lg:hidden relative flex h-full flex-col overflow-hidden">
                <SideDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)} />

                {fabOpen && (
                    <div className="absolute inset-0 z-20 bg-black/40 backdrop-blur-sm" onClick={() => setFabOpen(false)} />
                )}

                <header className="flex shrink-0 items-center justify-between px-3 py-2 md:px-5 md:py-3">
                    <Button variant="ghost" size="icon-sm" onClick={() => setDrawerOpen(true)}>
                        <GridCircle size={26} />
                    </Button>
                    <h1 className="text-lg font-bold tracking-tight">
                        Faith<span className="text-primary">Connect</span>
                    </h1>
                    <div className="flex items-center gap-1">
                        <ThemeToggle />
                        <div className="relative">
                            <button onClick={() => setProfileOpen((v) => !v)} className="relative">
                                <Avatar className="size-8 cursor-pointer ring-2 ring-border">
                                    <AvatarFallback className="bg-primary text-primary-foreground text-xs font-bold">
                                        {user?.initials ?? "Y"}
                                    </AvatarFallback>
                                </Avatar>
                            </button>
                            {profileOpen && (
                                <>
                                    <div className="fixed inset-0 z-40" onClick={() => setProfileOpen(false)} />
                                    <div className="absolute right-0 top-full z-50 mt-2 w-64 rounded-2xl border border-border bg-card p-4 shadow-xl">
                                        <div className="flex items-center gap-3">
                                            <Avatar size="lg">
                                                <AvatarFallback className="bg-primary text-primary-foreground text-base">
                                                    {user?.initials ?? "Y"}
                                                </AvatarFallback>
                                            </Avatar>
                                            <div>
                                                <p className="font-semibold">{user?.name ?? "User"}</p>
                                                <p className="text-xs text-muted-foreground">{user?.role ?? "Member"}</p>
                                            </div>
                                        </div>
                                        <div className="mt-2 flex items-center gap-2 rounded-xl border border-border px-3 py-2">
                                            <Church size={16} className="text-muted-foreground" />
                                            <p className="flex-1 text-sm font-medium">{user?.org ?? "Church"}</p>
                                        </div>
                                        <Separator className="my-3" />
                                        <div className="space-y-1">
                                            <Link href="/account" onClick={() => setProfileOpen(false)}
                                                className="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-semibold hover:bg-muted transition-colors">
                                                <User size={16} /> Profile
                                            </Link>
                                            <Link href="/account/settings" onClick={() => setProfileOpen(false)}
                                                className="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-semibold hover:bg-muted transition-colors">
                                                <Gear size={16} /> Settings
                                            </Link>
                                        </div>
                                        <Separator className="my-3" />
                                        <button onClick={() => { logout(); router.push("/login"); setProfileOpen(false) }}
                                            className="flex w-full items-center gap-3 rounded-xl px-3 py-2 text-sm font-semibold text-destructive hover:bg-destructive/10 transition-colors">
                                            <ArrowRightFromBracket size={16} /> Logout
                                        </button>
                                    </div>
                                </>
                            )}
                        </div>
                        <Button variant="ghost" size="icon-sm"><Bell size={20} /></Button>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto px-3 md:px-5">
                    <FeedContent />
                    <div className="pb-24" />
                </div>

                {/* FAB speed-dial — Church Owner only */}
                {user?.role === "Church Owner" && (
                    <div className="absolute bottom-4 right-4 z-30 flex flex-col-reverse items-end gap-3">
                        {fabOpen && fabItems.map((item, i) => (
                            <Link key={i} href={item.href} onClick={() => setFabOpen(false)}
                                className="flex items-center gap-3 animate-in slide-in-from-bottom-2 fade-in-0"
                                style={{ animationDelay: `${i * 40}ms` }}>
                                <span className="rounded-xl bg-background px-3 py-1.5 text-sm font-semibold shadow-md border border-border">{item.label}</span>
                                <div className="flex size-11 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                                    <item.Icon size={20} />
                                </div>
                            </Link>
                        ))}
                        <button
                            onClick={() => setFabOpen((v) => !v)}
                            className="flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform duration-200"
                            style={{ transform: fabOpen ? "rotate(45deg)" : "rotate(0deg)" }}>
                            {fabOpen ? <Xmark size={24} /> : <CirclePlus size={28} />}
                        </button>
                    </div>
                )}
            </div>
        </>
    )
}
