from __future__ import annotations

import threading
import time
from collections import defaultdict, deque


class RateLimiter:
    """Simple in-memory sliding window limiter, keyed per user."""

    def __init__(self, limit: int, window_s: float = 60.0) -> None:
        self._limit = limit
        self._window = window_s
        self._hits: dict[int, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()

    def allow(self, key: int) -> bool:
        now = time.monotonic()
        with self._lock:
            q = self._hits[key]
            while q and now - q[0] > self._window:
                q.popleft()
            if len(q) >= self._limit:
                return False
            q.append(now)
            return True
