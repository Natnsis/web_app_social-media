"use client"

import { useState, useCallback, useEffect } from "react"
import Link from "next/link"
import { useAuthStore, isTokenExpired } from "@/lib/store/auth"
import { useConversations } from "@/hooks/use-conversations"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { apiGetGroupComments } from "@/lib/api/groups"
import { ChatListItem } from "@/components/chat/chat-list-item"
import { MessageBubble } from "@/components/chat/message-bubble"
import { ChatInput } from "@/components/chat/chat-input"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { CirclePlus, CircleInformation, Search, Users } from "nasicon-react/outline"
import type { MessageEvent, GroupComment } from "@/types"

type TabType = "direct" | "groups"

function DesktopConversation({
  tab,
  conversationId,
  groupId,
  onSendMessage,
  onSendGroupMessage,
}: {
  tab: TabType
  conversationId?: string
  groupId?: string
  onSendMessage?: (text: string) => void
  onSendGroupMessage?: (text: string) => void
}) {
  const { user } = useAuthStore()
  const [dmMessages, setDmMessages] = useState<MessageEvent[]>([])
  const [groupMessages, setGroupMessages] = useState<GroupComment[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (tab === "groups" && groupId) {
      setLoading(true)
      apiGetGroupComments(groupId)
        .then((res) => {
          setGroupMessages(res.data ?? [])
          setLoading(false)
        })
        .catch(() => {
          setGroupMessages([])
          setLoading(false)
        })
    }
  }, [tab, groupId])

  return (
    <section className="flex min-w-0 flex-1 flex-col overflow-hidden bg-background">
      <header className="flex shrink-0 items-center gap-3 border-b border-border px-5 py-4">
        <Avatar>
          <AvatarFallback className="bg-primary/20 text-primary text-xs font-semibold">
            {tab === "groups" ? "G" : "?"}
          </AvatarFallback>
        </Avatar>
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-bold leading-tight">
            {tab === "groups" ? "Group Chat" : "Direct Message"}
          </p>
          <p className="text-[11px] text-muted-foreground">
            {tab === "groups" ? "Group conversation" : "Select a conversation"}
          </p>
        </div>
        <button type="button" className="flex size-8 items-center justify-center rounded-xl bg-primary text-primary-foreground">
          <CircleInformation size={16} />
        </button>
      </header>

      <div className="flex-1 space-y-3 overflow-y-auto px-6 py-5">
        {loading && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">Loading messages...</p>
          </div>
        )}

        {!loading && tab === "direct" && dmMessages.length === 0 && (
          <div className="flex h-full items-center justify-center">
            <p className="text-sm text-muted-foreground">No messages yet</p>
          </div>
        )}

        {tab === "direct" &&
          dmMessages.map((msg) => (
            <MessageBubble
              key={msg.id}
              text={msg.body}
              time={new Date(msg.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              from={msg.senderId === user?.id ? "me" : "them"}
              isRead={msg.isRead}
            />
          ))}

        {!loading && tab === "groups" && groupMessages.length === 0 && (
          <div className="flex h-full items-center justify-center">
            <p className="text-sm text-muted-foreground">No messages yet. Start the conversation!</p>
          </div>
        )}

        {tab === "groups" &&
          groupMessages.map((msg) => (
            <MessageBubble
              key={msg.id}
              text={msg.body}
              time={new Date(msg.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              from={msg.senderId === user?.id ? "me" : "them"}
            />
          ))}
      </div>

      <ChatInput
        onSend={(text) => {
          if (tab === "direct") onSendMessage?.(text)
          else onSendGroupMessage?.(text)
        }}
        placeholder={tab === "groups" ? "Type a group message..." : "Type a message..."}
      />
    </section>
  )
}

export default function ChatsPage() {
  const { user, accessToken } = useAuthStore()
  const tokenValid = !!(accessToken && !isTokenExpired(accessToken))
  const [tab, setTab] = useState<TabType>("direct")
  const [selectedChatId, setSelectedChatId] = useState<string | null>(null)
  const [selectedGroupId, setSelectedGroupId] = useState<string | null>(null)
  const [onlineUsers, setOnlineUsers] = useState<Set<string>>(new Set())

  const { data: convData } = useConversations(tokenValid)
  const conversations = convData?.data ?? []

  const enrichedConversations = conversations.map((conv) => {
    const other = conv.participantA.id === user?.id ? conv.participantB : conv.participantA
    const isOnline = onlineUsers.has(other.id) || other.isOnline
    return {
      id: conv.id,
      name: other.fullName,
      initials: other.initials || other.fullName.charAt(0).toUpperCase(),
      time: conv.lastMessage
        ? new Date(conv.lastMessage.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
        : "",
      lastMsg: conv.lastMessage?.body ?? "Start a conversation",
      unread: conv.unreadCount,
      online: isOnline,
    }
  })

  const selectedConv = enrichedConversations.find((c) => c.id === selectedChatId) ?? enrichedConversations[0]

  // ── Direct messaging socket ──
  const onPresenceOnline = useCallback(({ userId }: { userId: string }) => {
    setOnlineUsers((prev) => new Set(prev).add(userId))
  }, [])

  const onPresenceOffline = useCallback(({ userId }: { userId: string }) => {
    setOnlineUsers((prev) => {
      const next = new Set(prev)
      next.delete(userId)
      return next
    })
  }, [])

  const { sendMessage: sendDm } = useMessagingSocket(tokenValid, {
    onPresenceOnline,
    onPresenceOffline,
  })

  const handleSendDm = useCallback(
    (text: string) => {
      if (selectedChatId) sendDm({ conversationId: selectedChatId, body: text })
    },
    [selectedChatId, sendDm],
  )

  // ── Group socket ──
  const { sendMessage: sendGroupMessage } = useGroupSocket(tokenValid, {})

  const handleSendGroup = useCallback(
    (text: string) => {
      if (selectedGroupId) sendGroupMessage({ groupId: selectedGroupId, body: text })
    },
    [selectedGroupId, sendGroupMessage],
  )

  return (
    <div className="relative flex h-full flex-col overflow-hidden">
      <header className="flex shrink-0 items-center justify-between px-4 py-3 lg:hidden">
        <h1 className="text-xl font-bold">Chat</h1>
        <div className="flex items-center gap-2">
          <Avatar size="sm">
            <AvatarFallback className="bg-primary text-primary-foreground text-xs">{user?.initials ?? "AT"}</AvatarFallback>
          </Avatar>
          <Button variant="ghost" size="icon-sm"><Search size={20} /></Button>
        </div>
      </header>

      <div className="mx-4 mb-3 flex shrink-0 rounded-full bg-muted p-1 lg:hidden">
        {(["direct", "groups"] as const).map((t) => (
          <button
            key={t}
            onClick={() => {
              setTab(t)
              setSelectedChatId(null)
              setSelectedGroupId(null)
            }}
            className={`flex-1 rounded-full py-1.5 text-sm font-semibold capitalize transition-colors ${
              tab === t ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground"
            }`}
          >
            {t === "direct" ? "Direct" : "Groups"}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto pb-20 lg:hidden">
        {tab === "direct" &&
          enrichedConversations.map((chat) => (
            <ChatListItem key={chat.id} {...chat} href={`/chats/${chat.id}`} />
          ))}
        {tab === "groups" && (
          <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
            <Users size={40} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">
              {user?.role === "Church Owner" ? "Create your first group" : "No groups yet"}
            </p>
          </div>
        )}
      </div>

      <div className="hidden h-full min-h-0 overflow-hidden rounded-2xl border border-border bg-card lg:flex">
        <aside className="flex w-[344px] shrink-0 flex-col border-r border-border bg-card xl:w-96">
          <div className="border-b border-border px-4 py-4">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h1 className="text-xl font-black">Messages</h1>
                <p className="text-xs text-muted-foreground">Direct and ministry group chats</p>
              </div>
              {user?.role === "Church Owner" && (
                <Link
                  href="/chats/new-group"
                  className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground"
                >
                  <CirclePlus size={20} />
                </Link>
              )}
            </div>

            <div className="mt-4 flex rounded-xl bg-muted p-1">
              {(["direct", "groups"] as const).map((t) => (
                <button
                  key={t}
                  onClick={() => {
                    setTab(t)
                    setSelectedChatId(null)
                    setSelectedGroupId(null)
                  }}
                  className={`flex-1 rounded-lg py-2 text-sm font-semibold capitalize transition-colors ${
                    tab === t ? "bg-background text-foreground" : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  {t === "direct" ? "Direct" : "Groups"}
                </button>
              ))}
            </div>

            <div className="relative mt-3">
              <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
              <input
                placeholder="Search conversations"
                className="h-10 w-full rounded-xl border border-border bg-background pl-9 pr-3 text-sm outline-none focus:border-primary"
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {tab === "direct" &&
              (enrichedConversations.length === 0 ? (
                <div className="flex justify-center py-8 px-4">
                  <p className="text-sm text-muted-foreground">No conversations yet</p>
                </div>
              ) : (
                enrichedConversations.map((chat) => (
                  <ChatListItem
                    key={chat.id}
                    {...chat}
                    active={chat.id === selectedChatId}
                    onSelect={() => setSelectedChatId(chat.id)}
                  />
                ))
              ))}
            {tab === "groups" && (
              <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
                <Users size={40} className="text-muted-foreground/40" />
                <p className="text-sm text-muted-foreground">Select a group or create a new one</p>
              </div>
            )}
          </div>
        </aside>

        {tab === "direct" && selectedConv ? (
          <DesktopConversation
            tab="direct"
            conversationId={selectedConv.id}
            onSendMessage={handleSendDm}
          />
        ) : tab === "groups" && selectedGroupId ? (
          <DesktopConversation
            tab="groups"
            groupId={selectedGroupId}
            onSendGroupMessage={handleSendGroup}
          />
        ) : (
          <div className="flex flex-1 items-center justify-center">
            <p className="text-sm text-muted-foreground">
              {tab === "direct" ? "Select a conversation" : "Select or create a group"}
            </p>
          </div>
        )}
      </div>

      {user?.role === "Church Owner" && (
        <Link
          href="/chats/new-group"
          className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg lg:hidden"
        >
          <CirclePlus size={28} />
        </Link>
      )}
    </div>
  )
}
