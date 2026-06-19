"use client"

import { useState } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import Image from "next/image"
import { ImagePlus, Send, Xmark } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { useAuthStore } from "@/lib/store/auth"
import { useCreatePost } from "@/hooks/use-posts"
import { PenSquare, Play, CalendarDays, BookOpen } from "nasicon-react/outline"
import {
    BarChart3, CalendarClock, CheckCircle2, ChevronDown, Clock3, Eye,
    FileVideo, Hash, ImageIcon, MapPin, MessageCircle, Upload, Users,
} from "lucide-react"

const postTypes = [
    { value: "text", label: "Text", Icon: PenSquare },
    { value: "short", label: "Short", Icon: Play },
    { value: "event", label: "Event", Icon: CalendarDays },
    { value: "sermon", label: "Sermon", Icon: BookOpen },
]

export default function CreatePostPage() {
    const { user } = useAuthStore()
    const router = useRouter()
    const createPost = useCreatePost()
    const [postType, setPostType] = useState("text")
    const [title, setTitle] = useState("")
    const [content, setContent] = useState("")
    const [allowComments, setAllowComments] = useState(false)

    const handlePublish = async () => {
        if (!content.trim()) return
        try {
            await createPost.mutateAsync({
                content: content.trim(),
                ...(title.trim() ? { title: title.trim() } : {}),
                allowComments,
            })
            router.push("/")
        } catch (e) {
            console.error("Publish failed", e)
        }
    }

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
            <div className="hidden h-full overflow-y-auto bg-background p-4 lg:block">
                <div className="mx-auto grid min-h-full max-w-[1440px] grid-cols-[290px_minmax(0,1fr)_320px] gap-4">
                    <aside className="flex min-h-0 flex-col rounded-2xl border border-border bg-card p-4">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Studio</p>
                                <h2 className="mt-1 text-xl font-black">Media Library</h2>
                            </div>
                            <Button variant="outline" size="icon-sm" className="rounded-lg"><Upload size={16} /></Button>
                        </div>

                        <button className="mt-5 flex aspect-[4/3] flex-col items-center justify-center rounded-xl border border-dashed border-primary/35 bg-primary/5 text-center transition-colors hover:bg-primary/10">
                            <div className="flex size-11 items-center justify-center rounded-xl bg-background text-primary">
                                <ImagePlus size={22} />
                            </div>
                            <p className="mt-3 text-sm font-bold">Upload media</p>
                            <p className="mt-1 max-w-44 text-xs text-muted-foreground">Photos, sermons, reels, carousels</p>
                        </button>

                        <div className="mt-5 grid grid-cols-3 gap-2">
                            {Array.from({ length: 9 }).map((_, i) => (
                                <button
                                    key={i}
                                    className={`relative aspect-square overflow-hidden rounded-xl border border-border bg-gradient-to-br ${
                                        i % 3 === 0 ? "from-primary/25 to-primary/5" : i % 3 === 1 ? "from-primary/15 to-muted" : "from-muted to-primary/10"
                                    }`}
                                    aria-label={`Select media ${i + 1}`}
                                >
                                    {i === 0 && <Image src="/background.jpg" alt="" fill className="object-cover" sizes="90px" />}
                                    {i === 2 && <FileVideo className="absolute bottom-2 right-2 text-white drop-shadow" size={18} />}
                                </button>
                            ))}
                        </div>

                        <div className="mt-auto rounded-xl bg-primary p-4 text-primary-foreground">
                            <p className="text-xs font-bold uppercase tracking-wider text-primary-foreground/60">This month</p>
                            <div className="mt-4 grid grid-cols-2 gap-3">
                                <div>
                                    <p className="text-2xl font-black">42</p>
                                    <p className="text-[11px] text-primary-foreground/60">posts</p>
                                </div>
                                <div>
                                    <p className="text-2xl font-black">18k</p>
                                    <p className="text-[11px] text-primary-foreground/60">views</p>
                                </div>
                            </div>
                        </div>
                    </aside>

                    <main className="min-w-0 rounded-2xl border border-border bg-card p-4">
                        <div className="flex items-start justify-between gap-4">
                            <div>
                                <Link href="/account" className="text-xs font-semibold text-primary hover:underline">Account / Content Studio</Link>
                                <h1 className="mt-1 text-3xl font-black tracking-tight">Create Post</h1>
                                <p className="mt-1 text-sm text-muted-foreground">Publish articles, events, shorts, sermons, and live updates from one polished workspace.</p>
                            </div>
                            <div className="flex gap-2">
                                <Button variant="outline" className="rounded-xl">Save Draft</Button>
                                <Button className="rounded-xl gap-2" disabled={createPost.isPending} onClick={handlePublish}>
                                    {createPost.isPending ? "Publishing..." : "Publish"}
                                </Button>
                            </div>
                        </div>

                        <Tabs value={postType} onValueChange={setPostType} className="mt-6">
                            <TabsList className="grid h-auto w-full grid-cols-4 rounded-xl bg-muted/60 p-1">
                                {postTypes.map((t) => (
                                    <TabsTrigger
                                        key={t.value}
                                        value={t.value}
                                        className="gap-2 rounded-lg py-2.5 text-sm font-bold data-active:bg-background"
                                    >
                                        <t.Icon size={16} />
                                        {t.label}
                                    </TabsTrigger>
                                ))}
                            </TabsList>
                        </Tabs>

                        <div className="mt-6 grid grid-cols-2 gap-4">
                            <label className="space-y-2">
                                <span className="text-sm font-bold">Title</span>
                                <input className="h-11 w-full rounded-xl border border-border bg-muted/35 px-4 text-sm outline-none transition focus:border-primary" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Add a title (optional)" />
                            </label>
                            <label className="space-y-2">
                                <span className="text-sm font-bold">Audience</span>
                                <button className="flex h-11 w-full items-center justify-between rounded-xl border border-border bg-muted/35 px-4 text-sm">
                                    Public community <ChevronDown size={16} />
                                </button>
                            </label>
                        </div>

                        <div className="mt-4 rounded-xl border border-border bg-background p-4">
                            <div className="mb-3 flex items-center gap-3">
                                <Avatar size="sm">
                                    <AvatarFallback className="bg-primary text-primary-foreground text-xs font-bold">
                                        {user?.initials ?? "AT"}
                                    </AvatarFallback>
                                </Avatar>
                                <div>
                                    <p className="text-sm font-bold">{user?.name ?? "Abebe Tesfaye"}</p>
                                    <p className="text-xs text-muted-foreground">{user?.org ?? "Beza International"} channel</p>
                                </div>
                            </div>
                            <Textarea
                                placeholder="Share what God has laid on your heart..."
                                value={content}
                                onChange={(e) => setContent(e.target.value)}
                                className="min-h-44 rounded-xl border-none bg-muted/35 p-4 text-base leading-relaxed placeholder:text-muted-foreground/55 focus-visible:ring-0"
                            />
                            <div className="mt-3 flex flex-wrap gap-2">
                                {["#Worship", "#PrayerNight", "#Community"].map((tag) => (
                                    <span key={tag} className="inline-flex items-center gap-1 rounded-lg bg-primary/10 px-3 py-1 text-xs font-bold text-primary">
                                        <Hash size={12} /> {tag.replace("#", "")}
                                    </span>
                                ))}
                            </div>
                        </div>

                        <div className="mt-4 grid grid-cols-3 gap-3">
                            {[
                                { label: "Location", value: "Main Sanctuary", Icon: MapPin },
                                { label: "Schedule", value: "Tonight, 8:00 PM", Icon: CalendarClock },
                                { label: "Collaborators", value: "Worship Team", Icon: Users },
                            ].map(({ label, value, Icon }) => (
                                <button key={label} className="rounded-xl border border-border bg-background p-4 text-left transition-colors hover:border-primary/40">
                                    <Icon size={18} className="text-primary" />
                                    <p className="mt-3 text-xs text-muted-foreground">{label}</p>
                                    <p className="mt-1 truncate text-sm font-bold">{value}</p>
                                </button>
                            ))}
                        </div>

                        <div className="mt-5 flex items-center justify-between rounded-xl border border-border bg-background p-4">
                            <div className="flex items-center gap-3">
                                <div className="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                    <MessageCircle size={19} />
                                </div>
                                <div>
                                    <p className="text-sm font-bold">Allow Comments</p>
                                    <p className="text-xs text-muted-foreground">Let members respond with reflections and prayer requests</p>
                                </div>
                            </div>
                            <Switch checked={allowComments} onCheckedChange={setAllowComments} />
                        </div>
                    </main>

                    <aside className="flex min-h-0 flex-col gap-4">
                        <div className="rounded-2xl border border-border bg-card p-4">
                            <div className="mb-4 flex items-center justify-between">
                                <p className="text-sm font-black">Content Preview</p>
                                <Badge variant="outline" className="rounded-lg">Desktop + mobile</Badge>
                            </div>
                            <div className="mx-auto w-[245px] rounded-2xl border border-border bg-background p-3">
                                <div className="mb-3 flex items-center gap-2">
                                    <Avatar className="size-8">
                                        <AvatarFallback className="bg-primary/15 text-primary text-[10px] font-bold">{user?.initials ?? "AT"}</AvatarFallback>
                                    </Avatar>
                                    <div className="min-w-0">
                                        <p className="truncate text-xs font-bold">{user?.org ?? "Beza International"}</p>
                                        <p className="text-[10px] text-muted-foreground">Just now</p>
                                    </div>
                                </div>
                                <div className="relative aspect-[4/5] overflow-hidden rounded-xl bg-muted">
                                    <Image src="/background.jpg" alt="Post preview" fill className="object-cover" sizes="245px" />
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/35 to-transparent" />
                                </div>
                                <p className="mt-3 line-clamp-3 text-xs leading-relaxed">
                                    {content || "Share what God has laid on your heart..."}
                                </p>
                                <div className="mt-3 flex items-center justify-between text-muted-foreground">
                                    <HeartPreview />
                                    <MessageCircle size={15} />
                                    <CornerPreview />
                                    <BookmarkPreview />
                                </div>
                            </div>
                        </div>

                        <div className="rounded-2xl border border-border bg-card p-4">
                            <p className="text-sm font-black">Readiness</p>
                            <div className="mt-4 space-y-3">
                                {[
                                    { label: "Media attached", Icon: ImageIcon },
                                    { label: "Caption ready", Icon: CheckCircle2 },
                                    { label: "Best time selected", Icon: Clock3 },
                                ].map(({ label, Icon }) => (
                                    <div key={label} className="flex items-center gap-3 rounded-xl bg-muted/45 px-3 py-2">
                                        <Icon size={16} className="text-primary" />
                                        <span className="text-xs font-bold">{label}</span>
                                    </div>
                                ))}
                            </div>
                            <div className="mt-4 grid grid-cols-2 gap-3">
                                <div className="rounded-xl bg-primary/10 p-3">
                                    <Eye size={16} className="text-primary" />
                                    <p className="mt-2 text-lg font-black">6.2k</p>
                                    <p className="text-[10px] text-muted-foreground">est. reach</p>
                                </div>
                                <div className="rounded-xl bg-muted/60 p-3">
                                    <BarChart3 size={16} className="text-primary" />
                                    <p className="mt-2 text-lg font-black">9.4%</p>
                                    <p className="text-[10px] text-muted-foreground">engagement</p>
                                </div>
                            </div>
                        </div>
                    </aside>
                </div>
            </div>

            <div className="flex h-full flex-col overflow-hidden lg:hidden">
            <header className="flex shrink-0 items-center justify-between border-b border-border px-4 py-3">
                <Link href="/account"
                    className="flex size-8 items-center justify-center rounded-full bg-muted text-muted-foreground hover:bg-muted/80 transition-colors">
                    <Xmark size={18} />
                </Link>
                <h1 className="text-base font-bold">New Post</h1>
                <div className="w-8" />
            </header>

            <div className="shrink-0 border-b border-border px-4 py-4">
                <Tabs value={postType} onValueChange={setPostType}>
                    <TabsList className="flex w-full gap-1.5 bg-muted/50 p-1 rounded-xl h-auto">
                        {postTypes.map((t) => (
                            <TabsTrigger
                                key={t.value}
                                value={t.value}
                                className="flex-1 gap-1.5 rounded-lg py-2 text-xs font-semibold data-active:bg-background data-active:shadow-sm data-active:text-foreground text-muted-foreground"
                            >
                                <t.Icon size={14} />
                                {t.label}
                            </TabsTrigger>
                        ))}
                    </TabsList>
                </Tabs>
            </div>

            <div className="flex-1 overflow-y-auto px-4 pb-24 space-y-5 pt-5">
                {/* Author row */}
                <div className="flex items-center gap-3">
                    <Avatar size="sm">
                        <AvatarFallback className="bg-primary text-primary-foreground text-xs font-bold">
                            {user?.initials ?? "AT"}
                        </AvatarFallback>
                    </Avatar>
                    <div>
                        <p className="text-sm font-semibold">{user?.name ?? "Abebe Tesfaye"}</p>
                        <p className="text-[11px] text-muted-foreground">{postType === "short" ? "Creating a short" : "Writing a post"}</p>
                    </div>
                </div>

                {/* Textarea */}
                <div className="rounded-2xl border border-border bg-card p-4">
                    <Textarea
                        placeholder="Share what God has laid on your heart..."
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        className="min-h-36 border-none bg-transparent px-0 text-base leading-relaxed placeholder:text-muted-foreground/50 focus-visible:ring-0 resize-none"
                    />
                </div>

                {/* Image upload */}
                <button className="flex w-full items-center gap-4 rounded-2xl border-2 border-dashed border-border bg-card/50 px-5 py-6 transition-colors hover:bg-card hover:border-primary/50">
                    <div className="flex size-12 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <ImagePlus size={22} className="text-primary" />
                    </div>
                    <div className="text-left">
                        <p className="text-sm font-semibold">Add Image</p>
                        <p className="text-xs text-muted-foreground">PNG, JPG or WEBP (optional)</p>
                    </div>
                </button>

                {/* Allow comments */}
                <div className="flex items-center justify-between rounded-2xl border border-border bg-card p-4">
                    <div className="flex items-center gap-3">
                        <div className="flex size-10 items-center justify-center rounded-full bg-primary/10">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" /></svg>
                        </div>
                        <div>
                            <p className="text-sm font-semibold">Allow Comments</p>
                            <p className="text-xs text-muted-foreground">Let people share their reflections</p>
                        </div>
                    </div>
                    <Switch checked={allowComments} onCheckedChange={setAllowComments} />
                </div>
            </div>

            <div className="shrink-0 border-t border-border bg-background px-4 py-4">
                <Button className="h-12 w-full rounded-2xl text-base font-semibold gap-2 shadow-sm" disabled={createPost.isPending} onClick={handlePublish}>
                    <Send size={18} />
                    {createPost.isPending ? "Publishing..." : "Publish"}
                </Button>
            </div>
            </div>
        </div>
    )
}

function HeartPreview() {
    return (
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 1 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8z" />
        </svg>
    )
}

function CornerPreview() {
    return (
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M15 3h6v6" />
            <path d="M10 14 21 3" />
            <path d="M21 14v4a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3h4" />
        </svg>
    )
}

function BookmarkPreview() {
    return (
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M19 21 12 17 5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
        </svg>
    )
}
