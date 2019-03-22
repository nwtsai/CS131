import java.util.concurrent.locks.ReentrantLock;

class BetterSafe implements State {
	private byte[] value;
	private byte maxval;
	private final ReentrantLock rl = new ReentrantLock();

	BetterSafe(byte[] v) { value = v; maxval = 127; }

	BetterSafe(byte[] v, byte m) { value = v; maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j) {
		rl.lock();
		if (value[i] <= 0 || value[j] >= maxval) {
			rl.unlock();
			return false;
		}
		value[i]--;
		value[j]++;
		rl.unlock();
		return true;
	}
}
