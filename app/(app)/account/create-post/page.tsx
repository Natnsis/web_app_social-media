"use client"

import { useState } from "react"
import Link from "next/link"
import { ImagePlus, Send, Xmark } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { useAuthStore } from "@/lib/store/auth"
import { PenSquare, Play, CalendarDays, BookOpen } from "nasicon-react/outline"

const postTypes = [
    { value: "text", label: "Text", Icon: PenSquare },
    { value: "short", label: "Short", Icon: Play },
    { value: "event", label: "Event", Icon: CalendarDays },
    { value: "sermon", label: "Sermon", Icon: BookOpen },
]

export default function CreatePostPage() {
    const { user } = useAuthStore()
    const [postType, setPostType] = useState("text")
    const [content, setContent] = useState("")
    const [allowComments, setAllowComments] = useState(false)

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
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
                <Button className="h-12 w-full rounded-2xl text-base font-semibold gap-2 shadow-sm">
                    <Send size={18} />
                    Publish
                </Button>
            </div>
        </div>
    )
}
