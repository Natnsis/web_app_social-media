import { io, Socket } from "socket.io-client"
import { useAuthStore } from "@/lib/store/auth"

const SOCKET_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000"

const sockets = new Map<string, Socket>()

function getToken() {
  return useAuthStore.getState().accessToken
}

async function refreshToken() {
  const { refreshToken } = useAuthStore.getState()
  if (!refreshToken) return null
  try {
    const res = await fetch(`${SOCKET_URL}/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    })
    if (!res.ok) return null
    const data = await res.json()
    useAuthStore.getState().setAuthData(data.data.accessToken, data.data.refreshToken)
    return data.data.accessToken
  } catch {
    return null
  }
}

export function connectNamespace(namespace: string): Socket | null {
  const token = getToken()
  if (!token) return null

  const existing = sockets.get(namespace)
  if (existing?.connected) return existing

  const socket = io(`${SOCKET_URL}${namespace}`, {
    auth: { token },
    transports: ["websocket"],
    reconnection: true,
    reconnectionDelay: 2000,
    reconnectionAttempts: Infinity,
  })

  socket.on("connect", () => {
    console.log(`[socket] Connected to ${namespace} namespace (${socket.id})`)
  })

  socket.on("connect_error", async (err) => {
    console.error(`[socket] Connection error on ${namespace}:`, err.message)
    if (err.message === "WS_AUTH_FAILED") {
      const newToken = await refreshToken()
      if (newToken) {
        socket.auth = { token: newToken }
        socket.connect()
      }
    }
  })

  socket.on("error", ({ event, message }: { event?: string; message?: string }) => {
    console.error(`[socket] Error on ${namespace}${event ? ` (event: ${event})` : ""}:`, message)
  })

  socket.on("disconnect", (reason) => {
    console.log(`[socket] Disconnected from ${namespace}:`, reason)
    if (reason === "io server disconnect") {
      sockets.delete(namespace)
    }
  })

  sockets.set(namespace, socket)
  return socket
}

export function disconnectNamespace(namespace: string) {
  const socket = sockets.get(namespace)
  if (socket) {
    socket.disconnect()
    sockets.delete(namespace)
  }
}

export function getSocket(namespace: string): Socket | undefined {
  return sockets.get(namespace)
}

export function disconnectAll() {
  sockets.forEach((socket, ns) => {
    socket.disconnect()
    sockets.delete(ns)
  })
}
