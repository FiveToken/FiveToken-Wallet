# FiveToken 

FiveToken, to provide professional transaction service for Filecoin storage providers and to bridge Filecoin ecosystem to Web 3 metaverse with reliable ID management.

## The original intention of the project

Web 3.0 is the decentralized web promising to make the internet free again. FiveToken can liberate individual data to let the users get their individual sovereign back again. We plan to build up the system enabling users connect to the storage networking and interact with any DApps on any blockchains via one and only identity formed on metaverse and will never change and that the user can take everywhere. The identity management system can help users avoid data duplication, data breaches and identity theft. And the DApps can also be lightweight as a result of the shifted function of data storage on FiveToken. Once the system is completed, FiveToken will be capable to launch a comprehensive reputation system to help make the metaverse a safe place. 

## Introduction of  product

The future of Filecoin ecosystem and Web3 network are highly expected especially when the related applications are booming because it means Filecoin network has converted the data value from storing to flowing. But from the perspective of Token Infrastructure, Filecoin ecosystem is lacking a product that can both offer professional token service for miners and help Filecoin to expand its awareness to the big blockchain world and the broader communities. Web 3 is lacking a decentralized and comprehensive payment app like PayPal.

FiveToken targets to solve the problems via developing cross-chain payment protocol, designing interlayer that supports RPC network and realizing the closed loop of transaction, payment and reputation system. We want to support more than Filecoin and also have features more than a wallet, to help expand the application scenario of Filecoin and to proactively be a systematic DApp in Web 3 network. The system can be divided into 3 components:

- Payment: 

  Multi-chain mode/protocol can support Filecoin to link to other blockchains to build a seamless interoperability from Filecoin network to the web 3 metaverse.

- Identity:

  1. To enforce the capability of information management via all individual identity accounts and data communication across varied blockchains;
  2. To enhance the connection of the decentralized network to the identity in the real world to support all potential applications on Filecoin applied to the real world;

- Reputation system:

  1. To support Filecoin network to more decentralized DApps and help its application in the real world;
  2. To enhance the management (eps. self management) of decentralized individual identity. It can help utilize the reputation system in the real world to the decentralized network;

## Multi-chain version roadmap

- BSC, ETH and related DApps;（completed）
- Users can select chains independently（completed）
- Polkadot and related Dapps;
- Cross-chain payment protocol
- NFT management, storage and encryption 
- Protocol of ID verification and real-data storage (read-write) 
- Decentralized verification of real IDs 
- Reputation system based on real IDs

## How to run

### Required dependencies

- Flutter (Channel stable, 2.5.3, Tools • Dart 2.14.4）
- Android toolchain - develop for Android devices (Android SDK )
- Xcode - develop for iOS and macOS 
- Android Studio 

After install the dependencies above, clone this project and enter the root directory. Then you can run `flutter pub get` to install third-party code required for this project. When the above operations are completed，run `flutter run` to start app.

## Run Unit Test

`flutter test`

## How to build

### Android

Just run `flutter build apk`

### IOS

- Run `flutter build ios`
- Open the ios directory in Xcode
- Click Product -> Archive 

## How to use

Check [FiveToken Documentation](https://docs.fivetoken.io/userguide/app.html)

## License

[MIT](https://github.com/FiveToken/FiveToken-Wallet/blob/master/LICENSE)

## Links

[Project structure](./doc/code-tree.txt)

[functional-module](./functional-module.md)

[Release log](./doc/release.md)

[Design documents](./doc/impl.md)

[FiveToken new private key management plan](https://github.com/FiveToken/Design-Spec/blob/master/FiveToken%20new%20private%20key%20management%20plan.md)