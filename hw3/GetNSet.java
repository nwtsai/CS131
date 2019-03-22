import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
	private AtomicIntegerArray value;
	private byte maxval;

	private byte[] byteCopy() {
		int valueLength = size();
		byte[] newValue = new byte[valueLength];
		for (int i = 0; i < valueLength; i++) {
			newValue[i] = (byte) value.get(i);
		}
		return newValue;
	}

	private void ArrayCopy(byte[] v) {
		int valueLength = v.length;
		value = new AtomicIntegerArray(valueLength);
		for (int i = 0; i < valueLength; i++) {
			value.set(i, v[i]);
		}
	}

	GetNSet(byte[] v) { ArrayCopy(v); maxval = 127; }

	GetNSet(byte[] v, byte m) { ArrayCopy(v); maxval = m; }

	public int size() { return value.length(); }

	public byte[] current() { return byteCopy(); }

	public boolean swap(int i, int j) {
		int valAtI = value.get(i);
		int valAtJ = value.get(j);
		if (valAtI <= 0 || valAtJ >= maxval) {
			return false;
		}
		value.set(i, --valAtI);
		value.set(j, ++valAtJ);
		return true;
	}
}
