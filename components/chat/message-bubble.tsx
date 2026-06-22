"use client"

interface MessageBubbleProps {
  text: string
  time: string
  from: "me" | "them"
  isRead?: boolean
}

export function MessageBubble({ text, time, from, isRead }: MessageBubbleProps) {
  return (
    <div className={`flex flex-col gap-0.5 ${from === "me" ? "items-end" : "items-start"}`}>
      <div
        className={`max-w-[75%] rounded-2xl px-3.5 py-2.5 text-sm leading-relaxed ${
          from === "me"
            ? "rounded-br-sm bg-primary text-primary-foreground"
            : "rounded-bl-sm bg-muted text-foreground"
        }`}
      >
        {text}
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
