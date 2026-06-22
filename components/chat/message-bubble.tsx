"use client"

import Image from "next/image"

interface MessageBubbleProps {
  text: string
  time: string
  from: "me" | "them"
  isRead?: boolean
  mediaUrl?: string | null
}

export function MessageBubble({ text, time, from, isRead, mediaUrl }: MessageBubbleProps) {
  return (
    <div className={`flex flex-col gap-0.5 ${from === "me" ? "items-end" : "items-start"}`}>
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
