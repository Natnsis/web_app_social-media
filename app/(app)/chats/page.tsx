"use client"

import { useState, useCallback, useEffect, useRef } from "react"
import Link from "next/link"
import { useAuthStore, isTokenExpired } from "@/lib/store/auth"
import { useConversations, useConversation } from "@/hooks/use-conversations"
import { useGroups, useGroupComments } from "@/hooks/use-groups"
import { useMessagingSocket } from "@/hooks/use-messaging-socket"
import { useGroupSocket } from "@/hooks/use-group-socket"
import { getSocket } from "@/lib/socket"
import { ChatListItem } from "@/components/chat/chat-list-item"
import { MessageBubble } from "@/components/chat/message-bubble"
import { ChatInput } from "@/components/chat/chat-input"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { CirclePlus, CircleInformation, Search, Users } from "nasicon-react/outline"
import type { MessageEvent } from "@/types"

type TabType = "direct" | "groups"

function DesktopConversation({
  tab,
  conversationId,
  groupId,
  otherParticipant,
  onSendMessage,
  onSendGroupMessage,
  onSendRead,
}: {
  tab: TabType
  conversationId?: string
  groupId?: string
  otherParticipant?: { fullName: string; initials: string; isOnline: boolean; lastSeenText: string | null } | null
  onSendMessage?: (text: string) => void
  onSendGroupMessage?: (text: string) => void
  onSendRead?: (conversationId: string) => void
}) {
  const { user } = useAuthStore()

  // ── Direct messages ──

  const [dmMessages, setDmMessages] = useState<MessageEvent[]>([])
  const [dmTypingUserId, setDmTypingUserId] = useState<string | null>(null)

  const { data: convDetail, isLoading: convLoading } = useConversation(
    tab === "direct" ? conversationId ?? null : null,
  )

  const messages = convDetail?.data ?? null

  const prevConvIdRef = useRef<string | null>(null)

  // Seed dmMessages from API when conversationId changes (first load only)
  useEffect(() => {
    if (tab !== "direct" || !conversationId || !messages) return
    if (prevConvIdRef.current !== conversationId) {
      prevConvIdRef.current = conversationId
      setDmMessages(messages)
      setDmTypingUserId(null)
    }
  }, [conversationId, tab, messages])

  // Socket listeners for real-time DM updates
  useEffect(() => {
    if (tab !== "direct" || !conversationId) return
    const socket = getSocket("/messaging")
    if (!socket) return

    const onNew = (msg: MessageEvent) => {
      if (msg.conversationId === conversationId) {
        setDmMessages((prev) => [...prev, msg])
      }
    }
    const onUpdated = (msg: MessageEvent) => {
      if (msg.conversationId === conversationId) {
        setDmMessages((prev) => prev.map((m) => (m.id === msg.id ? msg : m)))
      }
    }
    const onDeleted = ({ conversationId: cId, messageId }: { conversationId: string; messageId: string }) => {
      if (cId === conversationId) {
        setDmMessages((prev) => prev.filter((m) => m.id !== messageId))
      }
    }
    const onTypingStart = ({ conversationId: cId, userId }: { conversationId: string; userId: string }) => {
      if (cId === conversationId && userId !== user?.id) setDmTypingUserId(userId)
    }
    const onTypingStop = ({ conversationId: cId }: { conversationId: string }) => {
      if (cId === conversationId) setDmTypingUserId(null)
    }

    socket.on("message:new", onNew)
    socket.on("message:updated", onUpdated)
    socket.on("message:deleted", onDeleted)
    socket.on("typing:start", onTypingStart)
    socket.on("typing:stop", onTypingStop)

    onSendRead?.(conversationId)

    return () => {
      socket.off("message:new", onNew)
      socket.off("message:updated", onUpdated)
      socket.off("message:deleted", onDeleted)
      socket.off("typing:start", onTypingStart)
      socket.off("typing:stop", onTypingStop)
    }
  }, [conversationId, tab, user?.id, onSendRead])

  // ── Group messages ──

  const {
    data: groupCommentsData,
    isLoading: groupCommentsLoading,
  } = useGroupComments(tab === "groups" ? groupId ?? null : null)

  const groupMessages = Array.isArray(groupCommentsData)
    ? groupCommentsData
    : Array.isArray(groupCommentsData?.data)
      ? groupCommentsData.data
      : []

  return (
    <section className="flex min-w-0 flex-1 flex-col overflow-hidden bg-background">
      <header className="flex shrink-0 items-center gap-3 border-b border-border px-5 py-4">
        {tab === "direct" && otherParticipant ? (
          <>
            <Avatar>
              <AvatarFallback className="bg-primary/20 text-primary text-xs font-semibold">
                {otherParticipant.fullName.charAt(0).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-bold leading-tight">{otherParticipant.fullName}</p>
              <div className="flex items-center gap-1">
                <div className={`size-1.5 rounded-full ${otherParticipant.isOnline ? "bg-green-500" : "bg-muted-foreground/30"}`} />
                <p className="text-[11px] text-muted-foreground">
                  {otherParticipant.isOnline ? "Active now" : otherParticipant.lastSeenText ?? "Offline"}
                </p>
              </div>
            </div>
          </>
        ) : (
          <>
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
          </>
        )}
        <button type="button" className="flex size-8 items-center justify-center rounded-xl bg-primary text-primary-foreground">
          <CircleInformation size={16} />
        </button>
      </header>

      <div className="flex-1 space-y-3 overflow-y-auto px-6 py-5">
        {convLoading && tab === "direct" && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">Loading messages...</p>
          </div>
        )}

        {groupCommentsLoading && tab === "groups" && (
          <div className="flex justify-center py-8">
            <p className="text-sm text-muted-foreground">Loading messages...</p>
          </div>
        )}

        {!convLoading && tab === "direct" && dmMessages.length === 0 && (
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

        {!groupCommentsLoading && tab === "groups" && groupMessages.length === 0 && (
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

        {dmTypingUserId && tab === "direct" && (
          <div className="flex items-start">
            <div className="rounded-2xl rounded-bl-sm bg-muted px-3.5 py-2.5 text-sm text-muted-foreground">
              <span className="animate-pulse">typing...</span>
            </div>
          </div>
        )}
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
  const { user } = useAuthStore()
  const [tab, setTab] = useState<TabType>("direct")
  const [selectedChatId, setSelectedChatId] = useState<string | null>(null)
  const [selectedGroupId, setSelectedGroupId] = useState<string | null>(null)
  const [onlineUsers, setOnlineUsers] = useState<Set<string>>(new Set())

  const { data: convData, isLoading: convsLoading, isError: convsError } = useConversations()
  const { data: groupsData, isLoading: groupsLoading, isError: groupsError } = useGroups()
  const { data: groupCommentsData, isLoading: groupCommentsLoading } = useGroupComments(
    tab === "groups" ? selectedGroupId : null
  )

  const conversations = convData?.data ?? []
  const groups = groupsData?.data ?? []

  const enrichedConversations = conversations.map((conv) => {
    const otherA = conv?.participantA
    const otherB = conv?.participantB
    const other = otherA?.id === user?.id ? otherB : otherA
    const isOnline = other?.id ? (onlineUsers.has(other.id) || other?.isOnline) : false
    const msgs = conv?.messages
    const lastMsg = msgs && msgs.length > 0 ? msgs[msgs.length - 1] : null
    return {
      id: conv?.id ?? "",
      name: other?.fullName || "Unknown",
      initials: other?.initials || other?.fullName?.charAt(0).toUpperCase() || "U",
      time: lastMsg?.createdAt
        ? new Date(lastMsg.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
        : "",
      lastMsg: lastMsg?.body ?? "Start a conversation",
      unread: 0,
      online: isOnline,
      otherParticipant: other
        ? {
            fullName: other.fullName,
            initials: other.initials || other.fullName.charAt(0).toUpperCase(),
            isOnline,
            lastSeenText: other.lastSeenText ?? null,
          }
        : null,
    }
  })
  const selectedConv = enrichedConversations.length > 0
    ? (enrichedConversations.find((c) => c.id === selectedChatId) ?? enrichedConversations[0])
    : null

  const { isAuthenticated } = useAuthStore()

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

  const { sendMessage: sendDm, sendRead } = useMessagingSocket(isAuthenticated, {
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
  const { sendMessage: sendGroupMessage } = useGroupSocket(isAuthenticated, {})

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
            className={`flex-1 rounded-full py-1.5 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground"
              }`}
          >
            {t === "direct" ? "Direct" : "Groups"}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto pb-20 lg:hidden">
        {tab === "direct" && convsLoading && (
          <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading conversations...</p></div>
        )}
        {tab === "direct" && convsError && (
          <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load conversations</p></div>
        )}
        {tab === "direct" && !convsLoading && !convsError && enrichedConversations.length === 0 && (
          <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
            <Users size={40} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">No conversations yet</p>
          </div>
        )}
        {tab === "direct" &&
          enrichedConversations.map((chat) => (
            <ChatListItem key={chat.id} {...chat} href={`/chats/${chat.id}`} />
          ))}
        {tab === "groups" && groupsLoading && (
          <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading groups...</p></div>
        )}
        {tab === "groups" && groupsError && (
          <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load groups</p></div>
        )}
        {tab === "groups" && !groupsLoading && !groupsError && groups.length === 0 && (
          <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
            <Users size={40} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">
              {user?.role === "Church Owner" ? "Create your first group" : "No groups yet"}
            </p>
          </div>
        )}
        {tab === "groups" &&
          groups.map((group) => (
            <ChatListItem
              key={group?.id}
              id={group?.id ?? ""}
              name={group?.name ?? "Group"}
              initials={group?.name?.slice(0, 2).toUpperCase() ?? "G"}
              time={
                group?.updatedAt
                  ? new Date(group.updatedAt).toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                  })
                  : ""
              }
              lastMsg={`${group?._count?.comments ?? 0} messages · ${group?.church?.name ?? ""}`}
              unread={0}
              online={false}
              href={`/chats/${group?.id}?type=group`}
            />
          ))}
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
                  className={`flex-1 rounded-lg py-2 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-background text-foreground" : "text-muted-foreground hover:text-foreground"
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
            {tab === "direct" && convsLoading && (
              <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading conversations...</p></div>
            )}
            {tab === "direct" && convsError && (
              <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load conversations</p></div>
            )}
            {tab === "direct" && !convsLoading && !convsError && enrichedConversations.length === 0 && (
              <div className="flex justify-center py-8 px-4">
                <p className="text-sm text-muted-foreground">No conversations yet</p>
              </div>
            )}
            {tab === "direct" &&
              enrichedConversations.map((chat) => (
                <ChatListItem
                  key={chat.id}
                  {...chat}
                  active={chat.id === selectedChatId}
                  onSelect={() => setSelectedChatId(chat.id)}
                />
              ))}
            {tab === "groups" && groupsLoading && (
              <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading groups...</p></div>
            )}
            {tab === "groups" && groupsError && (
              <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load groups</p></div>
            )}
            {tab === "groups" && !groupsLoading && !groupsError && groups.length === 0 && (
              <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
                <Users size={40} className="text-muted-foreground/40" />
                <p className="text-sm text-muted-foreground">
                  {user?.role === "Church Owner" ? "Create your first group" : "No groups yet"}
                </p>
              </div>
            )}
            {tab === "groups" &&
              groups.map((group) => (
                <ChatListItem
                  key={group?.id}
                  id={group?.id ?? ""}
                  name={group?.name ?? "Group"}
                  initials={group?.name?.slice(0, 2).toUpperCase() ?? "G"}
                  time={
                    group?.updatedAt
                      ? new Date(group.updatedAt).toLocaleTimeString([], {
                        hour: "2-digit",
                        minute: "2-digit",
                      })
                      : ""
                  }
                  lastMsg={`${group?._count?.comments ?? 0} messages · ${group?.church?.name ?? ""}`}
                  unread={0}
                  online={false}
                  active={group?.id === selectedGroupId}
                  onSelect={() => {
                    setSelectedGroupId(group?.id)
                    setSelectedChatId(null)
                  }}
                />
              ))}
          </div>
        </aside>

        {tab === "direct" && selectedConv ? (
          <DesktopConversation
            tab="direct"
            conversationId={selectedConv.id}
            otherParticipant={selectedConv.otherParticipant}
            onSendMessage={handleSendDm}
            onSendRead={sendRead}
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
