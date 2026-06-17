"use client"

import { useState } from "react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Separator } from "@/components/ui/separator"
import {
    Sheet, SheetContent, SheetHeader, SheetTitle,
} from "@/components/ui/sheet"
import {
    Heart, MessageSquare, CornerUpRight, MusicNote, Send, Link, Mail,
} from "nasicon-react/outline"
import { Heart as HeartSolid } from "nasicon-react/solid"

const shortsData = [
    {
        id: 1,
        creator: "Beza Internatio...",
        creatorInitials: "BI",
        description: "Powerful worship session at Beza International Church. #Worship #Addis",
        audio: "Original Audio - Beza Worship Team",
        likes: 12000,
        comments: 856,
        bg: "from-gray-900 to-gray-700",
        commentList: [
            { id: 1, user: "Sister Sara", initials: "SS", text: "Amen! 🙏 This blessed my soul.", time: "2m" },
            { id: 2, user: "Brother Yared", initials: "BY", text: "Glory to God! Share this everywhere.", time: "5m" },
            { id: 3, user: "Pastor Elias", initials: "PE", text: "What a powerful moment of worship.", time: "10m" },
        ],
    },
    {
        id: 2,
        creator: "Grace Community",
        creatorInitials: "GC",
        description: "Sunday praise and worship highlights. Come join us every week!",
        audio: "Praise Him - Grace Choir",
        likes: 8500,
        comments: 410,
        bg: "from-blue-900 to-blue-700",
        commentList: [
            { id: 1, user: "Faith Walker", initials: "FW", text: "Our church family is everything ❤️", time: "1m" },
            { id: 2, user: "Hope Ministry", initials: "HM", text: "God is so good!", time: "8m" },
        ],
    },
    {
        id: 3,
        creator: "Hope Valley",
        creatorInitials: "HV",
        description: "Evening prayer service live recording. Be blessed!",
        audio: "Still - Hope Valley Worship",
        likes: 5200,
        comments: 290,
        bg: "from-purple-900 to-purple-700",
        commentList: [
            { id: 1, user: "New Life", initials: "NL", text: "This touched my heart deeply.", time: "3m" },
        ],
    },
]

type Short = typeof shortsData[0]

function ShortItem({ short }: { short: Short }) {
    const [liked, setLiked] = useState(false)
    const [likes, setLikes] = useState(short.likes)
    const [commentOpen, setCommentOpen] = useState(false)
    const [shareOpen, setShareOpen] = useState(false)
    const [commentText, setCommentText] = useState("")
    const [comments, setComments] = useState(short.commentList)

    function handleLike() {
        setLiked((v) => !v)
        setLikes((v) => (liked ? v - 1 : v + 1))
    }

    function formatCount(n: number) {
        return n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n)
    }

    function sendComment() {
        if (!commentText.trim()) return
        setComments((prev) => [
            { id: prev.length + 1, user: "You", initials: "AT", text: commentText.trim(), time: "now" },
            ...prev,
        ])
        setCommentText("")
    }

    return (
        <div className="relative h-full w-full shrink-0 snap-start overflow-hidden">
            <div className={`absolute inset-0 bg-gradient-to-b ${short.bg}`} />
            <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-black/60 to-transparent" />
            <div className="absolute inset-x-0 bottom-0 h-64 bg-gradient-to-t from-black/80 to-transparent" />

            <div className="absolute inset-x-0 top-0 flex items-center justify-center py-4 z-10">
                <h1 className="text-base font-bold text-white tracking-wide">Shorts</h1>
            </div>

            {/* Right actions */}
            <div className="absolute right-3 bottom-32 z-10 flex flex-col items-center gap-5">
                <button onClick={handleLike} className="flex flex-col items-center gap-1">
                    {liked
                        ? <HeartSolid size={28} className="text-red-500" />
                        : <Heart size={28} className="text-white" />}
                    <span className="text-xs font-semibold text-white">{formatCount(likes)}</span>
                </button>

                <button onClick={() => setCommentOpen(true)} className="flex flex-col items-center gap-1">
                    <MessageSquare size={28} className="text-white" />
                    <span className="text-xs font-semibold text-white">{formatCount(comments.length + short.comments)}</span>
                </button>

                <button onClick={() => setShareOpen(true)} className="flex flex-col items-center gap-1">
                    <CornerUpRight size={28} className="text-white" />
                    <span className="text-xs font-semibold text-white">Share</span>
                </button>

                <div className="mt-1 size-10 rounded-full ring-2 ring-white bg-primary/60 flex items-center justify-center">
                    <span className="text-xs font-bold text-white">{short.creatorInitials}</span>
                </div>
            </div>

            {/* Bottom info */}
            <div className="absolute inset-x-0 bottom-6 z-10 px-4 pr-16">
                <div className="flex items-end gap-3">
                    <Avatar size="lg" className="shrink-0 ring-2 ring-white">
                        <AvatarFallback className="bg-primary text-white font-bold text-sm">
                            {short.creatorInitials}
                        </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0 space-y-1">
                        <div className="flex items-center gap-2">
                            <p className="font-bold text-white text-sm truncate">{short.creator}</p>
                            <Button size="xs" variant="outline"
                                className="shrink-0 rounded-full border-white bg-transparent text-white text-[11px] hover:bg-white/20">
                                Follow
                            </Button>
                        </div>
                        <p className="text-xs text-white/80 line-clamp-2">{short.description}</p>
                        <div className="flex items-center gap-1.5">
                            <MusicNote size={12} className="text-white shrink-0" />
                            <p className="text-[11px] text-white/80 truncate">{short.audio}</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Comments Sheet */}
            <Sheet open={commentOpen} onOpenChange={setCommentOpen}>
                <SheetContent side="bottom" showCloseButton={false}
                    className="max-h-[70%] rounded-t-3xl px-0 pb-0">
                    <SheetHeader className="px-4 pb-2">
                        <SheetTitle className="text-center text-sm">
                            {formatCount(comments.length + short.comments)} Comments
                        </SheetTitle>
                    </SheetHeader>
                    <Separator />
                    <div className="flex-1 overflow-y-auto px-4 py-3 space-y-4 max-h-[45vh]">
                        {comments.map((c) => (
                            <div key={c.id} className="flex gap-3">
                                <Avatar size="sm">
                                    <AvatarFallback className="bg-primary/20 text-primary text-xs">{c.initials}</AvatarFallback>
                                </Avatar>
                                <div className="flex-1">
                                    <div className="flex items-baseline gap-2">
                                        <p className="text-xs font-semibold">{c.user}</p>
                                        <p className="text-[10px] text-muted-foreground">{c.time}</p>
                                    </div>
                                    <p className="text-sm text-foreground">{c.text}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                    <div className="flex items-center gap-2 border-t border-border px-4 py-3">
                        <Avatar size="sm">
                            <AvatarFallback className="bg-primary text-white text-xs">AT</AvatarFallback>
                        </Avatar>
                        <Input
                            placeholder="Add a comment..."
                            value={commentText}
                            onChange={(e) => setCommentText(e.target.value)}
                            onKeyDown={(e) => e.key === "Enter" && sendComment()}
                            className="flex-1 rounded-full h-9"
                        />
                        <button onClick={sendComment} className="text-primary">
                            <Send size={20} />
                        </button>
                    </div>
                </SheetContent>
            </Sheet>

            {/* Share Sheet */}
            <Sheet open={shareOpen} onOpenChange={setShareOpen}>
                <SheetContent side="bottom" showCloseButton={false}
                    className="rounded-t-3xl px-0">
                    <SheetHeader className="px-4 pb-2">
                        <SheetTitle className="text-center text-sm">Share</SheetTitle>
                    </SheetHeader>
                    <Separator />
                    <div className="px-4 py-4 space-y-4">
                        <div className="flex gap-4 overflow-x-auto pb-2">
                            {[
                                { label: "Copy Link", Icon: Link, color: "bg-gray-100 dark:bg-gray-800" },
                                { label: "Direct", Icon: Send, color: "bg-blue-50 dark:bg-blue-950" },
                                { label: "Email", Icon: Mail, color: "bg-green-50 dark:bg-green-950" },
                                { label: "More", Icon: CornerUpRight, color: "bg-purple-50 dark:bg-purple-950" },
                            ].map((item) => (
                                <button key={item.label} className="flex shrink-0 flex-col items-center gap-2">
                                    <div className={`flex size-14 items-center justify-center rounded-full ${item.color}`}>
                                        <item.Icon size={22} className="text-foreground" />
                                    </div>
                                    <span className="text-xs text-muted-foreground">{item.label}</span>
                                </button>
                            ))}
                        </div>
                        <div className="flex items-center gap-2 rounded-xl border border-border bg-muted px-3 py-2">
                            <p className="flex-1 truncate text-xs text-muted-foreground">
                                https://faithconnect.app/shorts/{short.id}
                            </p>
                            <Button size="xs" variant="outline">Copy</Button>
                        </div>
                    </div>
                    <div className="px-4 pb-4">
                        <Button variant="ghost" className="w-full" onClick={() => setShareOpen(false)}>
                            Cancel
                        </Button>
                    </div>
                </SheetContent>
            </Sheet>
        </div>
    )
}

export default function ShortsPage() {
    return (
        <div className="h-full w-full snap-y snap-mandatory overflow-y-scroll lg:px-12 xl:px-24 2xl:px-48">
            {shortsData.map((short) => (
                <div key={short.id} className="h-full w-full snap-start rounded-none lg:rounded-2xl overflow-hidden">
                    <ShortItem short={short} />
                </div>
            ))}
        </div>
    )
}
