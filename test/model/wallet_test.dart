import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/wallet.dart';
void main() {
  test("generate model wallet", () async {
    Wallet wal = Wallet(
      ck: '12',
      label: 'Ddd',
      address: '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e',
      type: '1',
      walletType: 0,
      balance: '0',
      push: false,
      mne: 'GM5GhtqD5psi89lie4x4ifdlgrfz3/0C3i9gsgGVPMZ8fS5jkhWWRG++xz+qTldT00zVmRPO4ULQBmnvg6eQz+xh07BaDemzpLhfhdbetB8=',
      skKek:'hEngKhJBmohbCLgELlcOnYe3EKdL7AMsna1RruIf6yg0oe6dRn6UHcEzDsPnT0Pdb7EtM64cmK1Udc/+kG/IW1poEdzBuTz0jjeYCL4XB9M=',
      digest: 'pjopmwVs2Of9A86xPX0dYg==');
    expect(wal.addr, '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e');
    expect(wal.addrWithNet, 'fxa45bc341e17e7bb8c3183644f6293e0a6d16071e');
  });

  test("generate model wallet price", () async {
   CoinPrice price =   CoinPrice.fromJson({
     'usd': 54.11,
     'cny': 240,
   });
   expect(price.rate, 54.11);
  });
}