import time

struct St {
mut:
	a int
}

fn f(shared x St, shared z St) {
	for _ in 0 .. reads_per_thread {
		rlock x { // other instances may read at the same time
			time.sleep(time.millisecond)
			assert x.a == 7 || x.a == 5
		}
	}
	lock z {
		z.a--
	}
}

const (
	reads_per_thread = 30
	read_threads     = 10
	writes           = 5
)

fn test_shared_lock() {
	// object with separate read/write lock
	shared x := &St{
		a: 5
	}
	shared z := &St{
		a: read_threads
	}
	for _ in 0 .. read_threads {
		go f(shared x, shared z)
	}
	for i in 0 .. writes {
		lock x { // wait for ongoing reads to finish, don't start new ones
			x.a = 17 // this should never be read
			time.sleep(50 * time.millisecond)
			x.a = if (i & 1) == 0 { 7 } else { 5 }
		} // now new reads are possible again
		time.sleep(20 * time.millisecond)
	}
	// wait until all read threads are finished
	for finished := false; true; {
		mut rr := 0
		rlock z {
			rr = z.a
			finished = z.a == 0
		}
		if finished {
			break
		}
		time.sleep(100 * time.millisecond)
	}
}