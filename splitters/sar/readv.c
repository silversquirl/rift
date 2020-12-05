#include <errno.h>
#include "readv.h"

ssize_t wrap_process_vm_readv(pid_t pid, const struct iovec *local_iov, unsigned long liovcnt, const struct iovec *remote_iov, unsigned long riovcnt, unsigned long flags);

ssize_t _process_vm_readv(pid_t pid, const struct iovec *local_iov, unsigned long liovcnt, const struct iovec *remote_iov, unsigned long riovcnt, unsigned long flags) {
	ssize_t x = wrap_process_vm_readv(pid, local_iov, liovcnt, remote_iov, riovcnt, flags);
	if (x < 0) {
		errno = -x;
		return -1;
	}
	return x;
}
