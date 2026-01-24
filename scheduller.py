import threading
import time
from collections import deque

class Scheduler:
    def __init__(self, total_workers=36):
        self.total_workers = total_workers
        self.available_workers = total_workers

        self.job_queue = deque()
        self.running_jobs = {}
        self.completed_jobs = []

        self.lock = threading.Lock()
        self.state = "IDLE"

    def submit_job(self, job_static):
        with self.lock:
            job = JobRuntime(job_static)
            self.job_queue.append(job)
            return job

    def _can_schedule(self, job):
        return self.available_workers >= job.static.workers

    def _assign(self, job):
        job.state = "RUNNING"
        job.assigned_workers = job.static.workers
        self.available_workers -= job.assigned_workers
        self.running_jobs[job.static.job_id] = job

    def _release(self, job_id):
        job = self.running_jobs.pop(job_id)
        self.available_workers += job.assigned_workers
        job.state = "DONE"
        self.completed_jobs.append(job)

    def tick(self):
        with self.lock:
            self.state = "BALANCING"

            while self.job_queue:
                job = self.job_queue[0]
                if not self._can_schedule(job):
                    break
                self.job_queue.popleft()
                self._assign(job)

            self.state = "RUNNING"

    def complete_job(self, job_id):
        with self.lock:
            self._release(job_id)