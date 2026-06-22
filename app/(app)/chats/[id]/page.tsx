"use client"

import { useEffect } from "react"
import { useParams, useRouter, useSearchParams } from "next/navigation"
import { ChatThread } from "@/components/chat/chat-thread"

export default function ChatConversationPage() {
  const params = useParams()
  const router = useRouter()
  const searchParams = useSearchParams()
  const id = params.id as string
  const isGroup = searchParams.get("type") === "group"
  const desktopHref = `/chats?chatId=${encodeURIComponent(id)}&type=${isGroup ? "group" : "direct"}`

  useEffect(() => {
    const media = window.matchMedia("(min-width: 1024px)")
    const moveToDesktopShell = () => {
      if (media.matches) router.replace(desktopHref)
    }

    moveToDesktopShell()
    media.addEventListener("change", moveToDesktopShell)
    return () => media.removeEventListener("change", moveToDesktopShell)
  }, [desktopHref, router])

  return (
    <>
      <div className="h-full lg:hidden">
        <ChatThread id={id} isGroup={isGroup} onBack={() => window.history.back()} />
      </div>
      <div className="hidden h-full items-center justify-center lg:flex">
        <p className="text-sm text-muted-foreground">Opening messages...</p>
      </div>
    </>
  )
}
