"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { ChevronLeft, ImagePlus } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"
import {
    Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select"
import { apiCreateGroup } from "@/lib/api/groups"

export default function NewGroupPage() {
    const router = useRouter()
    const [groupName, setGroupName] = useState("")
    const [description, setDescription] = useState("")
    const [category, setCategory] = useState("bible-study")
    const [isPrivate, setIsPrivate] = useState(true)
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)

    async function handleSubmit() {
        if (!groupName.trim()) {
            setError("Group name is required")
            return
        }
        setLoading(true)
        setError(null)
        try {
            const res = await apiCreateGroup({
                name: groupName.trim(),
                description: description.trim() || undefined,
                category,
                isPrivate,
            })
            router.push(`/chats/${res.data.id}`)
        } catch (e: any) {
            setError(e.message || "Failed to create group")
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
            <header className="flex shrink-0 items-center gap-2 px-4 py-3">
                <Link href="/chats" className="text-foreground">
                    <ChevronLeft size={22} />
                </Link>
                <h1 className="text-lg font-bold text-primary">New Group</h1>
            </header>

            <div className="flex-1 overflow-y-auto px-4 pb-24 space-y-5">
                {error && (
                    <div className="rounded-2xl bg-destructive/10 p-4 text-sm text-destructive">
                        {error}
                    </div>
                )}

                {/* Cover Image */}
                <div>
                    <p className="mb-2 text-sm font-semibold">Cover Image</p>
                    <button type="button" className="flex w-full flex-col items-center gap-2 rounded-2xl border-2 border-dashed border-border py-8">
                        <div className="flex size-14 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
                            <ImagePlus size={24} className="text-primary" />
                        </div>
                        <p className="text-sm font-semibold">Upload Cover Image</p>
                        <p className="text-xs text-muted-foreground">Recommended: 16:9 Aspect Ratio</p>
                    </button>
                </div>

                {/* Group Name */}
                <div className="space-y-1.5">
                    <label className="text-sm font-medium">Group Name</label>
                    <Input
                        placeholder="e.g., New Sanctuary Sound System"
                        value={groupName}
                        onChange={(e) => setGroupName(e.target.value)}
                        className="h-12 rounded-xl px-4"
                    />
                </div>

                {/* Category */}
                <div className="space-y-1.5">
                    <label className="text-sm font-medium">Category</label>
                    <Select value={category} onValueChange={(v) => { if (v) setCategory(v) }}>
                        <SelectTrigger className="h-12 w-full rounded-xl px-4">
                            <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="bible-study">Bible Study</SelectItem>
                            <SelectItem value="worship">Worship</SelectItem>
                            <SelectItem value="prayer">Prayer</SelectItem>
                            <SelectItem value="youth">Youth</SelectItem>
                            <SelectItem value="outreach">Outreach</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                {/* Description */}
                <div className="space-y-1.5">
                    <label className="text-sm font-medium">Description</label>
                    <Textarea
                        placeholder="Briefly describe the purpose of this group..."
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        className="min-h-24 rounded-xl px-4 py-3"
                    />
                </div>

                <Separator />

                {/* Governance */}
                <div>
                    <p className="mb-3 text-sm font-semibold text-primary">Governance &amp; Privacy</p>
                    <div className="flex items-center justify-between rounded-2xl border border-border bg-card px-4 py-3">
                        <p className="text-sm font-semibold">Private Group</p>
                        <Switch checked={isPrivate} onCheckedChange={setIsPrivate} />
                    </div>
                </div>
            </div>

            {/* CTA */}
            <div className="shrink-0 border-t border-border bg-background px-4 py-4">
                <Button
                    className="h-12 w-full rounded-2xl text-base font-semibold"
                    onClick={handleSubmit}
                    disabled={loading}
                >
                    {loading ? "Creating..." : "Create Group"}
                </Button>
            </div>
        </div>
    )
}
