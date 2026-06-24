"use client"

import { useState, useMemo, useCallback } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { useNotifications, useMarkAllNotificationsRead, useMarkNotificationRead } from "@/hooks/use-notifications"
import { Heart, Users, Gift, Bell } from "nasicon-react/outline"
import { MessageSquare, CheckCheck, ArrowLeft } from "lucide-react"
import type { NotificationEvent } from "@/types"

function timeAgo(dateStr: string): string {
  const now = Date.now()
  const date = new Date(dateStr).getTime()
  const diff = now - date
  const seconds = Math.floor(diff / 1000)
  if (seconds < 60) return "just now"
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  if (days < 7) return `${days}d ago`
  const weeks = Math.floor(days / 7)
  if (weeks < 4) return `${weeks}w ago`
  return new Date(dateStr).toLocaleDateString()
}

function getTypeIcon(type: string) {
  switch (type.toLowerCase()) {
    case "like":
      return <Heart size={16} className="text-red-500" />
    case "comment":
      return <MessageSquare size={16} className="text-blue-500" />
    case "follow":
      return <Users size={16} className="text-emerald-500" />
    case "campaign":
      return <Heart size={16} className="text-amber-500" />
    case "gift":
      return <Gift size={16} className="text-purple-500" />
    default:
      return <Bell size={16} className="text-muted-foreground" />
  }
}

function getInitials(n: NotificationEvent): string {
  if (n.data && typeof n.data === "object") {
    const d = n.data as Record<string, unknown>
    if (typeof d.initials === "string") return d.initials
    if (typeof d.name === "string") return d.name.charAt(0).toUpperCase()
  }
  return n.title.charAt(0).toUpperCase()
}

function getAvatarUrl(n: NotificationEvent): string | undefined {
  if (n.data && typeof n.data === "object") {
    const d = n.data as Record<string, unknown>
    if (typeof d.avatarUrl === "string") return d.avatarUrl
  }
  return undefined
}

const FILTERS = ["All", "Unread", "Likes", "Comments", "Follows", "Campaigns"] as const

function NotificationItem({
  n,
  onClick,
}: {
  n: NotificationEvent
  onClick: (n: NotificationEvent) => void
}) {
  return (
    <div
      onClick={() => onClick(n)}
      className={`flex cursor-pointer items-start gap-3 rounded-2xl px-4 py-3.5 transition-colors hover:bg-muted/50 ${!n.isRead ? "bg-primary/5" : ""}`}
    >
      <div className="relative shrink-0">
        <Avatar className="size-11">
          <AvatarImage src={getAvatarUrl(n)} />
          <AvatarFallback className="bg-muted text-xs font-medium">
            {getInitials(n)}
          </AvatarFallback>
        </Avatar>
        <div className="absolute -bottom-0.5 -right-0.5 flex size-5 items-center justify-center rounded-full border-2 border-background bg-card">
          {getTypeIcon(n.type)}
        </div>
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-sm">
          <span className="font-semibold">{n.title}</span>
          {n.body && <span className="text-muted-foreground"> {n.body}</span>}
        </p>
        <p className="mt-0.5 text-xs text-muted-foreground">{timeAgo(n.createdAt)}</p>
      </div>
      {!n.isRead && <div className="mt-1.5 size-2 shrink-0 rounded-full bg-blue-500" />}
    </div>
  )
}

function NotificationSkeleton({ count = 5 }: { count?: number }) {
  return (
    <div className="space-y-1">
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className="flex animate-pulse items-start gap-3 rounded-2xl p-4">
          <div className="size-11 shrink-0 rounded-full bg-muted" />
          <div className="flex-1 space-y-2">
            <div className="h-4 w-3/4 rounded bg-muted" />
            <div className="h-3 w-1/2 rounded bg-muted" />
          </div>
        </div>
      ))}
    </div>
  )
}

export default function NotificationsPage() {
  const router = useRouter()
  const [activeFilter, setActiveFilter] = useState<(typeof FILTERS)[number]>("All")
  const { data, isLoading, isError, refetch } = useNotifications()
  const markAllRead = useMarkAllNotificationsRead()
  const markRead = useMarkNotificationRead()

  const notifications = data?.data ?? []
  const unreadCount = notifications.filter((n) => !n.isRead).length

  const filtered = useMemo(() => {
    switch (activeFilter) {
      case "Unread":
        return notifications.filter((n) => !n.isRead)
      case "Likes":
        return notifications.filter((n) => n.type.toLowerCase() === "like")
      case "Comments":
        return notifications.filter((n) => n.type.toLowerCase() === "comment")
      case "Follows":
        return notifications.filter((n) => n.type.toLowerCase() === "follow")
      case "Campaigns":
        return notifications.filter((n) =>
          ["campaign", "gift"].includes(n.type.toLowerCase()),
        )
      default:
        return notifications
    }
  }, [notifications, activeFilter])

  function handleNotificationClick(n: NotificationEvent) {
    if (!n.isRead) markRead.mutate(n.id)
  }

  function handleMarkAllRead() {
    markAllRead.mutate()
  }

  function FilterChip({
    label,
    active,
    onClick,
  }: {
    label: string
    active: boolean
    onClick: () => void
  }) {
    return (
      <button
        onClick={onClick}
        className={`whitespace-nowrap rounded-full px-3.5 py-1.5 text-xs font-semibold transition-colors ${
          active
            ? "bg-primary text-primary-foreground"
            : "bg-muted text-muted-foreground hover:bg-muted/80"
        }`}
      >
        {label}
        {label === "Unread" && unreadCount > 0 && (
          <span className="ml-1.5 rounded-full bg-primary-foreground/20 px-1.5 text-[10px]">
            {unreadCount}
          </span>
        )}
      </button>
    )
  }

  return (
    <>
      {/* ── Desktop ── */}
      <div className="hidden h-full overflow-y-auto lg:block">
        <div className="mx-auto max-w-2xl px-6 py-8">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold">Notifications</h1>
              <p className="mt-0.5 text-sm text-muted-foreground">
                {unreadCount > 0 ? `${unreadCount} unread` : "All caught up"}
              </p>
            </div>
            {unreadCount > 0 && (
              <Button
                variant="outline"
                size="sm"
                onClick={handleMarkAllRead}
                disabled={markAllRead.isPending}
              >
                <CheckCheck size={14} className="mr-1" />
                Mark all read
              </Button>
            )}
          </div>

          <div className="mb-6 flex flex-wrap gap-2">
            {FILTERS.map((f) => (
              <FilterChip
                key={f}
                label={f}
                active={activeFilter === f}
                onClick={() => setActiveFilter(f)}
              />
            ))}
          </div>

          {isLoading && <NotificationSkeleton count={5} />}

          {isError && (
            <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
              <p className="text-sm text-muted-foreground">
                Failed to load notifications
              </p>
              <Button variant="outline" size="sm" onClick={() => refetch()}>
                Try again
              </Button>
            </div>
          )}

          {!isLoading && !isError && filtered.length === 0 && (
            <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
              <Bell size={32} className="text-muted-foreground/50" />
              <p className="text-sm font-semibold">No notifications yet</p>
              <p className="text-xs text-muted-foreground">
                When you get notifications, they&apos;ll show up here.
              </p>
            </div>
          )}

          {!isLoading && !isError && filtered.length > 0 && (
            <div className="space-y-1">
              {filtered.map((n) => (
                <NotificationItem
                  key={n.id}
                  n={n}
                  onClick={handleNotificationClick}
                />
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ── Mobile ── */}
      <div className="flex h-full flex-col lg:hidden">
        <header className="flex shrink-0 items-center justify-between border-b border-border bg-background/80 px-3 py-2 backdrop-blur-md md:px-5 md:py-3">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon-sm"
              onClick={() => router.back()}
            >
              <ArrowLeft size={20} />
            </Button>
            <h1 className="text-lg font-bold">Notifications</h1>
          </div>
          {unreadCount > 0 && (
            <Button
              variant="ghost"
              size="xs"
              onClick={handleMarkAllRead}
              disabled={markAllRead.isPending}
              className="text-xs font-semibold text-primary"
            >
              Mark all read
            </Button>
          )}
        </header>

        <div className="shrink-0 overflow-x-auto border-b border-border px-3 py-2 md:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          <div className="flex gap-2">
            {FILTERS.map((f) => (
              <FilterChip
                key={f}
                label={f}
                active={activeFilter === f}
                onClick={() => setActiveFilter(f)}
              />
            ))}
          </div>
        </div>

        <div className="flex-1 overflow-y-auto px-3 pb-24 pt-2 md:px-5">
          {isLoading && <NotificationSkeleton count={5} />}

          {isError && (
            <div className="mt-4 flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
              <p className="text-sm text-muted-foreground">
                Failed to load notifications
              </p>
              <Button variant="outline" size="sm" onClick={() => refetch()}>
                Try again
              </Button>
            </div>
          )}

          {!isLoading && !isError && filtered.length === 0 && (
            <div className="mt-4 flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
              <Bell size={32} className="text-muted-foreground/50" />
              <p className="text-sm font-semibold">No notifications yet</p>
              <p className="text-xs text-muted-foreground">
                When you get notifications, they&apos;ll show up here.
              </p>
            </div>
          )}

          {!isLoading && !isError && filtered.length > 0 && (
            <div className="space-y-1">
              {filtered.map((n) => (
                <NotificationItem
                  key={n.id}
                  n={n}
                  onClick={handleNotificationClick}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </>
  )
}
