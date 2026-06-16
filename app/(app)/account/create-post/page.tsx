"use client"

import { useState } from "react"
import Link from "next/link"
import { ImagePlus, Send } from "nasicon-react/outline"
import { Xmark } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"

const postTypes = [
    { value: "text", label: "Text", emoji: "📄" },
    { value: "short", label: "Short", emoji: "🎬" },
    { value: "event", label: "Event", emoji: "📅" },
    { value: "sermon", label: "Sermon", emoji: "📖" },
]

export default function CreatePostPage() {
    const [postType, setPostType] = useState("text")
    const [content, setContent] = useState("")
    const [allowComments, setAllowComments] = useState(false)

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
            <header className="flex shrink-0 items-center justify-between px-4 py-3">
                <Link href="/account"
                    className="flex size-8 items-center justify-center rounded-full bg-muted text-muted-foreground">
                    <Xmark size={18} />
                </Link>
                <h1 className="text-base font-bold">New Post</h1>
                <div className="w-8" />
            </header>

            <div className="shrink-0 px-4 pb-3">
                <Tabs value={postType} onValueChange={setPostType}>
                    <TabsList className="flex w-full gap-1 bg-transparent p-0 h-auto">
                        {postTypes.map((t) => (
                            <TabsTrigger
                                key={t.value}
                                value={t.value}
                                className="flex-1 gap-1 rounded-full border border-border py-1.5 text-xs data-active:border-primary data-active:bg-primary data-active:text-white"
                            >
                                {t.label}
                            </TabsTrigger>
                        ))}
                    </TabsList>
                </Tabs>
            </div>

            <div className="flex-1 overflow-y-auto px-4 pb-24 space-y-5">
                <Textarea
                    placeholder="Write your post..."
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    className="min-h-40 border-none bg-transparent px-0 text-lg placeholder:text-muted-foreground/60 focus-visible:ring-0"
                />

                {/* Image upload */}
                <button className="flex w-full flex-col items-center gap-3 rounded-2xl border-2 border-dashed border-border py-10">
                    <div className="flex size-14 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
                        <ImagePlus size={24} className="text-primary" />
                    </div>
                    <p className="text-sm font-bold">Add Image (optional)</p>
                    <p className="text-xs text-muted-foreground">Post text only or with an image</p>
                </button>

                {/* Allow comments */}
                <div className="flex items-start justify-between gap-4 py-2">
                    <div>
                        <p className="text-sm font-semibold">Allow Comments</p>
                        <p className="text-xs text-muted-foreground">Let people share their reflections</p>
                    </div>
                    <Switch checked={allowComments} onCheckedChange={setAllowComments} />
                </div>
            </div>

            <div className="shrink-0 border-t border-border bg-background px-4 py-4">
                <Button className="h-12 w-full rounded-2xl text-base font-semibold gap-2">
                    <Send size={18} />
                    Publish
                </Button>
            </div>
        </div>
    )
}
