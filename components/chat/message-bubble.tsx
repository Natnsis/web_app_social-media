"use client"

import { useState } from "react"
import Image from "next/image"
import { Trash } from "nasicon-react/outline"

interface MessageBubbleProps {
  text: string
  time: string
  from: "me" | "them"
  isRead?: boolean
  mediaUrl?: string | null
  onDelete?: () => void
}

export function MessageBubble({ text, time, from, isRead, mediaUrl, onDelete }: MessageBubbleProps) {
  const [showActions, setShowActions] = useState(false)

  return (
    <div
      className={`group relative flex flex-col gap-0.5 ${from === "me" ? "items-end" : "items-start"}`}
      onMouseEnter={() => setShowActions(true)}
      onMouseLeave={() => setShowActions(false)}
    >
      {from === "me" && showActions && onDelete && (
        <button
          onClick={onDelete}
          className="absolute -left-7 top-1 flex size-6 items-center justify-center rounded-full text-muted-foreground opacity-0 transition-opacity hover:text-destructive group-hover:opacity-100"
        >
          <Trash size={14} />
        </button>
      )}
      <div
        className={`max-w-[75%] rounded-2xl px-3.5 py-2.5 text-sm leading-relaxed ${
          from === "me"
            ? "rounded-br-sm bg-primary text-primary-foreground"
            : "rounded-bl-sm bg-muted text-foreground"
        }`}
      >
        {mediaUrl && (
          <div className="mb-1.5 overflow-hidden rounded-lg">
            <Image
              src={mediaUrl}
              alt="Shared image"
              width={240}
              height={180}
              className="h-auto w-full rounded-lg object-cover"
              style={{ maxHeight: 240 }}
              unoptimized
            />
          </div>
        )}
        {text && <p>{text}</p>}
      </div>
      <div className="flex items-center gap-1">
        <span className="text-[10px] text-muted-foreground">{time}</span>
        {from === "me" && isRead !== undefined && (
          <span className="text-[10px]">{isRead ? "✓✓" : "✓"}</span>
        )}
      </div>
    </div>
  )
}
