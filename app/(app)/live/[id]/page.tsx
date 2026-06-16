"use client"

import { useState, useRef, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Xmark, Heart, Send, Eye, Users } from "nasicon-react/outline"
import { Heart as HeartSolid } from "nasicon-react/solid"

const liveData: Record<string, { name: string; initials: string; viewers: number; topic: string }> = {
    "grace-ch": { name: "Grace Church", initials: "GC", viewers: 1240, topic: "Sunday Morning Worship" },
    "hope-val": { name: "Hope Valley", initials: "HV", viewers: 892, topic: "Evening Prayer Service" },
    "unity": { name: "Unity Church", initials: "UN", viewers: 540, topic: "Bible Study — John 15" },
    "the-well": { name: "The Well", initials: "TW", viewers: 3100, topic: "Worship Night Live" },
    "new-life": { name: "New Life", initials: "NL", viewers: 720, topic: "Youth Service" },
    "zion": { name: "Zion Ministries", initials: "ZN", viewers: 450, topic: "Midweek Service" },
}

const seedComments = [
    { id: 1, user: "Sister Sara", initials: "SS", text: "Amen! 🙏 This is so anointed!" },
    { id: 2, user: "Brother Yared", initials: "BY", text: "Glory to God! Keep worshipping!" },
    { id: 3, user: "Pastor Elias", initials: "PE", text: "The presence of God is here 🔥" },
    { id: 4, user: "Faith Walker", initials: "FW", text: "Watching from Addis. God bless!" },
    { id: 5, user: "Hope Ministry", initials: "HM", text: "This song always moves me 😭❤️" },
]

type Comment = { id: number; user: string; initials: string; text: string }

export default function LivePage({ params }: { params: Promise<{ id: string }> }) {
    const router = useRouter()
    const [id, setId] = useState<string | null>(null)
    const [liked, setLiked] = useState(false)
    const [likeCount, setLikeCount] = useState(0)
    const [comment, setComment] = useState("")
    const [comments, setComments] = useState<Comment[]>(seedComments)
    const bottomRef = useRef<HTMLDivElement>(null)

    // Resolve async params
    useEffect(() => {
        params.then((p) => setId(p.id))
    }, [params])

    // Auto-scroll comments
    useEffect(() => {
        bottomRef.current?.scrollIntoView({ behavior: "smooth" })
    }, [comments])

    // Simulate incoming comments
    useEffect(() => {
        const names = [
            { user: "Dawit T.", initials: "DT", text: "Hallelujah! 🙌" },
            { user: "Miriam A.", initials: "MA", text: "This worship is incredible!" },
            { user: "Samuel K.", initials: "SK", text: "God is good all the time 🙏" },
            { user: "Ruth B.", initials: "RB", text: "Watching from Nairobi ❤️" },
        ]
        let i = 0
        const interval = setInterval(() => {
            const msg = names[i % names.length]
            setComments((prev) => [
                ...prev,
                { id: Date.now(), user: msg.user, initials: msg.initials, text: msg.text },
            ])
            i++
        }, 4000)
        return () => clearInterval(interval)
    }, [])

    function sendComment() {
        if (!comment.trim()) return
        setComments((prev) => [
            ...prev,
            { id: Date.now(), user: "You", initials: "AT", text: comment.trim() },
        ])
        setComment("")
    }

    function handleLike() {
        setLiked((v) => !v)
        setLikeCount((v) => (liked ? v - 1 : v + 1))
    }

    if (!id) return null
    const stream = liveData[id] ?? { name: id, initials: "?", viewers: 0, topic: "Live Stream" }

    return (
        <div className="relative flex h-full w-full flex-col overflow-hidden bg-black">

            {/* Video placeholder */}
            <div className="absolute inset-0 bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900">
                <div className="absolute inset-0 flex items-center justify-center opacity-20">
                    <div className="size-32 rounded-full bg-primary/40" />
                </div>
            </div>

            {/* Top bar */}
            <div className="absolute inset-x-0 top-0 z-10 flex items-center justify-between px-4 pt-4 pb-8 bg-gradient-to-b from-black/70 to-transparent">
                <button onClick={() => router.back()}
                    className="flex size-8 items-center justify-center rounded-full bg-black/50 text-white">
                    <Xmark size={18} />
                </button>

                <div className="flex items-center gap-2">
                    <Badge className="bg-red-500 text-white border-none text-[11px] gap-1 rounded-full px-2 py-0.5">
                        <div className="size-1.5 rounded-full bg-white animate-pulse" />
                        LIVE
                    </Badge>
                    <div className="flex items-center gap-1 rounded-full bg-black/50 px-2 py-1">
                        <Eye size={12} className="text-white" />
                        <span className="text-[11px] font-semibold text-white">
                            {(stream.viewers + likeCount).toLocaleString()}
                        </span>
                    </div>
                </div>

                <button className="flex items-center gap-1 rounded-full bg-primary px-3 py-1.5">
                    <Users size={14} className="text-white" />
                    <span className="text-[11px] font-semibold text-white">Follow</span>
                </button>
            </div>

            {/* Creator info */}
            <div className="absolute left-4 top-20 z-10 flex items-center gap-2">
                <Avatar size="lg" className="ring-2 ring-white">
                    <AvatarFallback className="bg-primary text-primary-foreground font-bold">
                        {stream.initials}
                    </AvatarFallback>
                </Avatar>
                <div>
                    <p className="text-sm font-bold text-white">{stream.name}</p>
                    <p className="text-xs text-white/70">{stream.topic}</p>
                </div>
            </div>

            {/* Comments overlay — scrollable, fades at top */}
            <div className="absolute inset-x-0 bottom-16 z-10 flex max-h-[55%] flex-col justify-end overflow-hidden px-4 pb-2">
                <div className="flex flex-col gap-2 overflow-y-auto [mask-image:linear-gradient(transparent_0%,black_30%)]">
                    {comments.map((c) => (
                        <div key={c.id} className="flex items-start gap-2">
                            <Avatar size="sm" className="shrink-0">
                                <AvatarFallback className="bg-primary/60 text-white text-[10px]">{c.initials}</AvatarFallback>
                            </Avatar>
                            <div className="rounded-2xl bg-black/50 px-3 py-1.5 backdrop-blur-sm">
                                <span className="text-[11px] font-bold text-primary">{c.user} </span>
                                <span className="text-[12px] text-white">{c.text}</span>
                            </div>
                        </div>
                    ))}
                    <div ref={bottomRef} />
                </div>
            </div>

            {/* Right action rail */}
            <div className="absolute right-3 bottom-20 z-10 flex flex-col items-center gap-4">
                <button onClick={handleLike} className="flex flex-col items-center gap-1">
                    {liked
                        ? <HeartSolid size={28} className="text-red-500" />
                        : <Heart size={28} className="text-white" />}
                    <span className="text-[11px] font-semibold text-white">{likeCount > 0 ? likeCount : ""}</span>
                </button>
            </div>

            {/* Comment input */}
            <div className="absolute inset-x-0 bottom-0 z-10 flex items-center gap-2 bg-black/70 px-3 py-2 backdrop-blur-sm">
                <Avatar size="sm">
                    <AvatarFallback className="bg-primary text-primary-foreground text-[10px]">AT</AvatarFallback>
                </Avatar>
                <Input
                    placeholder="Say something..."
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && sendComment()}
                    className="h-9 flex-1 rounded-full border-white/20 bg-white/10 text-white placeholder:text-white/50 focus-visible:border-white/40 focus-visible:ring-white/20"
                />
                <Button size="icon-sm" onClick={sendComment}
                    className="shrink-0 rounded-full bg-primary">
                    <Send size={16} />
                </Button>
            </div>
        </div>
    )
}
