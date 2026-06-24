"use client"

import { useEffect, useRef, useState, useCallback, forwardRef, useImperativeHandle } from "react"
import { StreamPlayer } from "@xnstream/player-sdk"

export interface StreamPlayerHandle {
  play: () => Promise<void>
  pause: () => void
  isPaused: boolean
}

interface StreamPlayerProps {
  id: string
  appId: string
  streamCode: string
  playing?: boolean
  className?: string
}

export const StreamPlayerWrapper = forwardRef<StreamPlayerHandle, StreamPlayerProps>(
  function StreamPlayerWrapper({ id, appId, streamCode, playing = false, className }, ref) {
    const containerRef = useRef<HTMLDivElement>(null)
    const playerRef = useRef<StreamPlayer | null>(null)
    const [status, setStatus] = useState<"loading" | "ready" | "error">("loading")

    useImperativeHandle(ref, () => ({
      play: async () => {
        if (playerRef.current) {
          await playerRef.current.play()
        }
      },
      pause: () => {
        playerRef.current?.pause()
      },
      get isPaused() {
        return false
      },
    }))

    useEffect(() => {
      const container = containerRef.current
      if (!container) return

      if (!appId || !streamCode) {
        setStatus("error")
        return
      }

      let player: StreamPlayer | null = null

      async function init() {
        try {
          player = await StreamPlayer.create({
            appId,
            stream_code: streamCode,
            containerId: container!.id,
            autoPlay: playing,
          })
          playerRef.current = player

          player.on("ready", () => {
            setStatus("ready")
          })

          player.on("error", () => {
            setStatus("error")
          })

          await player.initialize()
          if (playing) {
            await player.play()
          }
        } catch {
          setStatus("error")
        }
      }

      init()

      return () => {
        if (playerRef.current) {
          try {
            playerRef.current.destroy()
          } catch {
            // player may not be fully initialized
          }
          playerRef.current = null
        }
      }
    }, [id, appId, streamCode]) // eslint-disable-line react-hooks/exhaustive-deps

    useEffect(() => {
      if (playerRef.current) {
        if (playing) {
          playerRef.current.play().catch(() => {})
        } else {
          playerRef.current.pause()
        }
      }
    }, [playing])

    return (
      <div className={`relative h-full w-full ${className ?? ""}`}>
        <div
          id={`player-${id}`}
          ref={containerRef}
          className="h-full w-full"
        />

        {status === "loading" && (
          <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-b from-gray-900 to-gray-800">
            <div className="flex flex-col items-center gap-3">
              <div className="size-8 animate-spin rounded-full border-2 border-white/30 border-t-white" />
              <p className="text-sm text-white/60">Loading video...</p>
            </div>
          </div>
        )}

        {status === "error" && (
          <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-b from-gray-900 to-gray-800">
            <div className="flex flex-col items-center gap-2 px-4 text-center">
              <p className="text-sm font-medium text-white/80">Video unavailable</p>
              <p className="text-xs text-white/50">This video may still be processing</p>
            </div>
          </div>
        )}
      </div>
    )
  }
)
