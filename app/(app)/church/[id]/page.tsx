"use client"

import { use, useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { useChurch } from "@/hooks/use-church"
import { useToggleFollowChurch } from "@/hooks/use-nearby-churches"
import {
    Heart, Users, Church, MapPin, Globe, Calendar, ArrowLeft,
} from "nasicon-react/outline"
import { Heart as HeartSolid } from "nasicon-react/solid"
import { Users as UsersIcon, BarChart3 } from "lucide-react"
import type { ChurchDetailData } from "@/types"

function getInitials(name: string): string {
    return name
        .split(" ")
        .map((w) => w[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
}

function cn(...classes: (string | boolean | undefined | null)[]) {
    return classes.filter(Boolean).join(" ")
}

/* ── Loading Shimmer ── */

function ChurchProfileShimmer() {
    return (
        <div className="animate-pulse">
            <div className="h-48 w-full bg-muted lg:hidden" />
            <div className="px-4 pb-6 lg:px-0 lg:pb-0">
                <div className="-mt-12 flex justify-center lg:-mt-0 lg:justify-start">
                    <div className="size-24 rounded-full bg-muted ring-4 ring-background lg:size-20" />
                </div>
                <div className="mt-4 space-y-3 text-center lg:text-left">
                    <div className="mx-auto h-6 w-48 rounded bg-muted lg:mx-0" />
                    <div className="mx-auto h-4 w-full max-w-md rounded bg-muted lg:mx-0" />
                    <div className="mx-auto h-10 w-32 rounded-xl bg-muted lg:mx-0" />
                </div>
                <div className="mt-6 flex justify-center gap-8 lg:justify-start">
                    {[1, 2, 3, 4].map((i) => (
                        <div key={i} className="space-y-1 text-center">
                            <div className="mx-auto h-5 w-10 rounded bg-muted" />
                            <div className="mx-auto h-3 w-14 rounded bg-muted" />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}

/* ── Stat Item ── */

function StatItem({ value, label }: { value: number | string; label: string }) {
    return (
        <div className="text-center">
            <p className="text-lg font-bold">{value ?? 0}</p>
            <p className="text-xs text-muted-foreground">{label}</p>
        </div>
    )
}

/* ── Tab Content Components ── */

function PostsContent({ church }: { church: ChurchDetailData }) {
    const posts = church.recentPosts ?? []

    if (posts.length === 0) {
        return (
            <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                <Church size={32} className="text-muted-foreground" />
                <p className="text-sm text-muted-foreground">No posts yet</p>
            </div>
        )
    }

    return (
        <div className="space-y-3">
            {posts.map((p: any) => (
                <div key={p.id} className="overflow-hidden rounded-2xl border border-border bg-card p-4">
                    {p.title && <p className="text-sm font-semibold">{p.title}</p>}
                    {p.content && (
                        <p className={cn("text-sm text-muted-foreground", p.title && "mt-1")}>{p.content}</p>
                    )}
                </div>
            ))}
        </div>
    )
}

function CampaignsContent({ church }: { church: ChurchDetailData }) {
    const campaigns = church.recentCampaigns ?? []

    if (campaigns.length === 0) {
        return (
            <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                <BarChart3 size={32} className="text-muted-foreground" />
                <p className="text-sm text-muted-foreground">No campaigns yet</p>
            </div>
        )
    }

    return (
        <div className="space-y-3">
            {campaigns.map((c: any) => (
                <div key={c.id} className="rounded-2xl border border-border bg-card p-4">
                    <p className="text-sm font-semibold">{c.title}</p>
                    {c.description && (
                        <p className="mt-1 text-xs text-muted-foreground line-clamp-2">{c.description}</p>
                    )}
                    {"goal" in c && c.goal && (
                        <div className="mt-3">
                            <div className="flex items-center justify-between text-xs text-muted-foreground mb-1">
                                <span>{c.goal.currency ?? "ETB"} {c.goal.currentAmount?.toLocaleString() ?? 0}</span>
                                <span>{c.goal.percentReached?.toFixed(0) ?? 0}%</span>
                            </div>
                            <div className="h-2 overflow-hidden rounded-full bg-muted">
                                <div
                                    className="h-full rounded-full bg-primary transition-all"
                                    style={{ width: `${Math.min(c.goal.percentReached ?? 0, 100)}%` }}
                                />
                            </div>
                        </div>
                    )}
                </div>
            ))}
        </div>
    )
}

function MembersContent({ church }: { church: ChurchDetailData }) {
    const owner = church.owner
    const moderators = church.moderators ?? []

    if (!owner && moderators.length === 0) {
        return (
            <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                <UsersIcon size={32} className="text-muted-foreground" />
                <p className="text-sm text-muted-foreground">No members yet</p>
            </div>
        )
    }

    return (
        <div className="space-y-3">
            {owner && (
                <div className="flex items-center gap-3 rounded-2xl border border-border bg-gradient-to-r from-primary/5 to-primary/10 p-4">
                    <Avatar className="size-12 ring-2 ring-primary/30">
                        <AvatarFallback className="bg-primary text-primary-foreground text-sm font-bold">
                            {getInitials(owner.fullName)}
                        </AvatarFallback>
                    </Avatar>
                    <div className="min-w-0 flex-1">
                        <p className="text-sm font-semibold">{owner.fullName}</p>
                        <Badge
                            variant="outline"
                            className="mt-1 border-primary/30 bg-primary/5 text-[10px] font-semibold text-primary"
                        >
                            <Users size={10} className="mr-1" />
                            Owner
                        </Badge>
                    </div>
                </div>
            )}
            {moderators.map((mod) => (
                <div
                    key={mod.id}
                    className="flex items-center gap-3 rounded-2xl border border-border bg-card p-4"
                >
                    <Avatar className="size-10">
                        <AvatarFallback className="bg-muted text-xs font-medium">
                            {getInitials(mod.user.fullName)}
                        </AvatarFallback>
                    </Avatar>
                    <div className="min-w-0 flex-1">
                        <p className="text-sm font-semibold">{mod.user.fullName}</p>
                        <p className="text-xs text-muted-foreground">Moderator</p>
                    </div>
                </div>
            ))}
        </div>
    )
}

function AboutContent({ church }: { church: ChurchDetailData }) {
    return (
        <div className="space-y-4">
            {church.description && (
                <div className="rounded-2xl border border-border bg-card p-4">
                    <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                        About
                    </p>
                    <p className="text-sm leading-relaxed">{church.description}</p>
                </div>
            )}
            <div className="rounded-2xl border border-border bg-card p-4">
                <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                    Details
                </p>
                <div className="space-y-3">
                    {church.address && (
                        <div className="flex items-center gap-2 text-sm">
                            <MapPin size={16} className="shrink-0 text-muted-foreground" />
                            <span>{church.address}</span>
                        </div>
                    )}
                    {church.websiteUrl && (
                        <a
                            href={church.websiteUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 text-sm text-primary hover:underline"
                        >
                            <Globe size={16} className="shrink-0 text-muted-foreground" />
                            <span className="truncate">{church.websiteUrl}</span>
                        </a>
                    )}
                    {church.email && (
                        <div className="flex items-center gap-2 text-sm">
                            <span className="shrink-0 text-base font-bold text-muted-foreground">@</span>
                            <span>{church.email}</span>
                        </div>
                    )}
                    {church.phoneNumber && (
                        <div className="flex items-center gap-2 text-sm">
                            <span className="shrink-0 text-base font-bold text-muted-foreground">&#9742;</span>
                            <span>{church.phoneNumber}</span>
                        </div>
                    )}
                    {church.city && (
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                            <Calendar size={16} className="shrink-0" />
                            <span>
                                {church.city}
                                {church.country ? `, ${church.country}` : ""}
                            </span>
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}

/* ── Desktop Sidebar Card ── */

function DesktopSidebarCard({
    church,
    isFollowing,
    onFollow,
}: {
    church: ChurchDetailData
    isFollowing: boolean
    onFollow: () => void
}) {
    return (
        <aside className="hidden w-72 shrink-0 lg:block">
            <div className="rounded-2xl border border-border bg-card p-6">
                <div className="flex flex-col items-center gap-3">
                    <Avatar className="size-20 ring-4 ring-primary/20">
                        <AvatarFallback className="bg-primary text-primary-foreground text-2xl font-bold">
                            {getInitials(church.name)}
                        </AvatarFallback>
                    </Avatar>
                    <div className="text-center">
                        <h2 className="text-lg font-bold">{church.name}</h2>
                        {church.description && (
                            <p className="mt-1 line-clamp-3 text-xs text-muted-foreground">{church.description}</p>
                        )}
                    </div>
                    <Button
                        variant={isFollowing ? "outline" : "default"}
                        size="sm"
                        className="w-full rounded-full"
                        onClick={onFollow}
                    >
                        {isFollowing ? (
                            <>
                                <HeartSolid size={14} className="mr-1" /> Following
                            </>
                        ) : (
                            <>
                                <Heart size={14} className="mr-1" /> Follow
                            </>
                        )}
                    </Button>
                </div>

                <Separator className="my-4" />

                <div className="grid grid-cols-2 gap-4">
                    <StatItem value={church._count.followers} label="Followers" />
                    <StatItem value={church._count.posts} label="Posts" />
                    <StatItem value={church._count.campaigns} label="Campaigns" />
                    <StatItem value={church._count.groups} label="Groups" />
                </div>

                <Separator className="my-4" />

                <div className="space-y-2">
                    {church.address && (
                        <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <MapPin size={14} className="shrink-0" />
                            <span className="truncate">{church.address}</span>
                        </div>
                    )}
                    {church.websiteUrl && (
                        <a
                            href={church.websiteUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 text-xs text-primary hover:underline"
                        >
                            <Globe size={14} className="shrink-0" />
                            <span className="truncate">{church.websiteUrl}</span>
                        </a>
                    )}
                    {church.email && (
                        <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <span className="shrink-0 text-[10px] font-bold text-muted-foreground/60">@</span>
                            <span className="truncate">{church.email}</span>
                        </div>
                    )}
                </div>
            </div>
        </aside>
    )
}

/* ── Tab Bar (shared between mobile and desktop) ── */

const tabs = [
    { value: "Posts", icon: Church },
    { value: "Campaigns", icon: Heart },
    { value: "Members", icon: Users },
    { value: "About", icon: Globe },
]

function ProfileTabsBar({ baseClass }: { baseClass?: string }) {
    return (
        <TabsList
            variant="line"
            className={cn(
                "flex w-full rounded-none border-b border-border bg-transparent pb-0",
                baseClass,
            )}
        >
            {tabs.map(({ value: tab, icon: Icon }) => (
                <TabsTrigger
                    key={tab}
                    value={tab}
                    className="flex-1 rounded-none border-b-2 border-transparent pb-2.5 pt-1 text-sm font-semibold data-active:border-primary data-active:bg-transparent data-active:text-primary lg:flex-none lg:px-4"
                >
                    <Icon size={15} className="sm:mr-1.5" />
                    <span className="hidden sm:inline">{tab}</span>
                </TabsTrigger>
            ))}
        </TabsList>
    )
}

function ProfileTabPanels({ church }: { church: ChurchDetailData }) {
    return (
        <>
            <TabsContent value="Posts">
                <PostsContent church={church} />
            </TabsContent>
            <TabsContent value="Campaigns">
                <CampaignsContent church={church} />
            </TabsContent>
            <TabsContent value="Members">
                <MembersContent church={church} />
            </TabsContent>
            <TabsContent value="About">
                <AboutContent church={church} />
            </TabsContent>
        </>
    )
}

/* ── Main Page ── */

export default function ChurchProfilePage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params)
    const router = useRouter()
    const { data, isLoading, isError, error, refetch } = useChurch(id)
    const toggleFollow = useToggleFollowChurch()
    const [optimisticFollowing, setOptimisticFollowing] = useState(false)

    const church = data?.data
    const isFollowing = church ? church.isFollowing ?? optimisticFollowing : optimisticFollowing

    useEffect(() => {
        if (church && church.isFollowing !== undefined) {
            setOptimisticFollowing(false)
        }
    }, [church?.isFollowing])

    const handleFollow = () => {
        if (!church) return
        const next = !isFollowing
        setOptimisticFollowing(next)
        toggleFollow.mutate({ id: church.id, following: church.isFollowing })
    }

    /* ── Loading ── */
    if (isLoading) {
        return (
            <div className="h-full overflow-y-auto">
                <ChurchProfileShimmer />
            </div>
        )
    }

    /* ── Error ── */
    if (isError) {
        return (
            <div className="flex h-full flex-col items-center justify-center gap-4 p-8 text-center">
                <p className="text-sm text-destructive">{error?.message ?? "Failed to load church profile"}</p>
                <Button variant="outline" size="sm" onClick={() => refetch()}>
                    Try again
                </Button>
                <Button variant="ghost" size="sm" onClick={() => router.back()}>
                    Go back
                </Button>
            </div>
        )
    }

    /* ── Not found ── */
    if (!church) {
        return (
            <div className="flex h-full flex-col items-center justify-center gap-4 p-8 text-center">
                <Church size={48} className="text-muted-foreground" />
                <p className="text-sm text-muted-foreground">Church not found</p>
                <Button variant="ghost" size="sm" onClick={() => router.back()}>
                    Go back
                </Button>
            </div>
        )
    }

    /* ── Render ── */
    return (
        <>
            {/* ── Mobile layout ── */}
            <div className="flex h-full flex-col overflow-hidden lg:hidden">
                {/* Cover image */}
                <div className="relative shrink-0">
                    <div
                        className="h-48 w-full bg-cover bg-center"
                        style={{
                            backgroundImage: church.coverImageUrl
                                ? `url(${church.coverImageUrl})`
                                : "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
                        }}
                    >
                        <div className="absolute inset-0 bg-gradient-to-b from-black/30 via-black/20 to-background" />
                    </div>
                    <button
                        onClick={() => router.back()}
                        className="absolute left-3 top-12 z-10 flex size-8 items-center justify-center rounded-full bg-black/30 text-white backdrop-blur-sm"
                        aria-label="Back"
                    >
                        <ArrowLeft size={18} />
                    </button>
                </div>

                {/* Church info */}
                <div className="relative z-10 -mt-12 flex flex-col items-center px-4">
                    <Avatar className="size-24 ring-4 ring-background">
                        <AvatarFallback className="bg-primary text-primary-foreground text-3xl font-bold">
                            {getInitials(church.name)}
                        </AvatarFallback>
                    </Avatar>
                    <h1 className="mt-3 text-center text-xl font-bold">{church.name}</h1>
                    {church.description && (
                        <p className="mt-1 line-clamp-2 text-center text-sm text-muted-foreground">
                            {church.description}
                        </p>
                    )}
                    <Button
                        variant={isFollowing ? "outline" : "default"}
                        size="sm"
                        className="mt-3 rounded-full"
                        onClick={handleFollow}
                    >
                        {isFollowing ? (
                            <>
                                <HeartSolid size={14} className="mr-1" /> Following
                            </>
                        ) : (
                            <>
                                <Heart size={14} className="mr-1" /> Follow
                            </>
                        )}
                    </Button>
                </div>

                {/* Stats row */}
                <div className="mt-5 flex justify-center gap-6 px-4">
                    <StatItem value={church._count.followers} label="Followers" />
                    <StatItem value={church._count.posts} label="Posts" />
                    <StatItem value={church._count.campaigns} label="Campaigns" />
                    <StatItem value={church._count.groups} label="Groups" />
                </div>

                {/* Tabs */}
                <Tabs defaultValue="Posts" className="mt-4 flex flex-1 flex-col overflow-hidden">
                    <ProfileTabsBar baseClass="px-4 shrink-0" />
                    <div className="flex-1 overflow-y-auto px-4 pb-6 pt-4">
                        <ProfileTabPanels church={church} />
                    </div>
                </Tabs>
            </div>

            {/* ── Desktop layout ── */}
            <div className="hidden h-full overflow-y-auto lg:block">
                <div className="mx-auto flex w-full max-w-5xl gap-8 px-8 pt-8">
                    <DesktopSidebarCard church={church} isFollowing={isFollowing} onFollow={handleFollow} />
                    <div className="min-w-0 flex-1">
                        <Tabs defaultValue="Posts">
                            <ProfileTabsBar />
                            <div className="pt-4">
                                <ProfileTabPanels church={church} />
                            </div>
                        </Tabs>
                    </div>
                </div>
                <div className="pb-10" />
            </div>
        </>
    )
}
