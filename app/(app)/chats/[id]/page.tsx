"use client"

import { useParams, useSearchParams } from "next/navigation"
import { ChatThread } from "@/components/chat/chat-thread"

export default function ChatConversationPage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const id = params.id as string
  const isGroup = searchParams.get("type") === "group"

  return <ChatThread id={id} isGroup={isGroup} onBack={() => window.history.back()} />
}
