"use client"

import { Avatar, AvatarFallback } from "@/components/ui/avatar"

interface ChatListItemProps {
  id: string
  name: string
  initials: string
  time: string
  lastMsg: string
  unread: number
  online: boolean
  active?: boolean
  href?: string
  onSelect?: () => void
}

export function ChatListItem({
  id,
  name,
  initials,
  time,
  lastMsg,
  unread,
  online,
  active,
  href,
  onSelect,
}: ChatListItemProps) {
  const content = (
    <>
      <div className="relative">
        <Avatar className="size-11">
          <AvatarFallback className="bg-primary/20 text-primary font-semibold text-sm">
            {initials}
          </AvatarFallback>
        </Avatar>
        {online && (
          <div className="absolute bottom-0 right-0 size-2.5 rounded-full bg-green-500 ring-2 ring-background" />
        )}
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between">
          <p className="truncate text-sm font-semibold">{name}</p>
          <span className="ml-2 shrink-0 text-[11px] text-muted-foreground">{time}</span>
        </div>
        <div className="mt-0.5 flex items-center justify-between">
          <p className="flex-1 truncate text-xs text-muted-foreground">{lastMsg}</p>
          {unread > 0 && (
            <span className="ml-2 flex size-5 shrink-0 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {unread}
            </span>
          )}
        </div>
      </div>
    </>
  )

  const className = `flex w-full items-center gap-3 px-4 py-3 text-left transition-colors ${
    active ? "bg-primary/10 text-foreground" : "hover:bg-muted/50"
  }`

  if (href) {
    return (
      <a href={href} className={className}>
        {content}
      </a>
    )
  }

  return (
    <button type="button" onClick={onSelect} className={className}>
      {content}
    </button>
  )
}
