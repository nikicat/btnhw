# BETTER THEN NOTHING HARDWARE WALLET

## 🚀 TL;DR

B.T.N.H.W is a hardware wallet designed for advanced users and developers working with EVM-compatible blockchains.

It is fully open source, highly customizable, and built on [7.85$ widely accessible components](https://www.amazon.com/Raspberry-Pi-Pico/dp/B09KVB8LVR). 


## 🤔 The reason

These days, it's common for blockchain developers and advanced users (who create their own tools for interacting with a blockchain) to store secret keys in plaintext .env files, configurations, or software wallets. This makes secret keys an easy target for attackers. B.T.N.H.W was created to address this issue (see the security section for details).

## 🛠️ How to use


**Prepare the Pico**

1. Download (or build on your own) the firmware.  Was tested with version 4.0.
2. Patch it with a valid VID:PID . Was tested with 1050:0407.

Or use the prepatred firmware from this repo.


**Testrun of the Wallet**

1. Clone the repo to your local environment.

2. Connect the Pico device with the appropriate firmware installed. You should see a log entry in dmesg indicating the device has been detected.

```
[7165950.673737] usb 1-8: New USB device found, idVendor=1050, idProduct=0407, bcdDevice= 6.00
[7165950.673746] usb 1-8: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[7165950.673752] usb 1-8: Product: Pico Key
[7165950.673756] usb 1-8: Manufacturer: Pol Henarejos
[7165950.673760] usb 1-8: SerialNumber: DE6398C5A3391327
```


3. Run docker compose build. This process can take some time, so feel free to make some coffee while you wait.

4. Execute ./test.sh. This script will:
   
    Initialize the hardware with an unsecured known key (for testing purposes only).
   
    Start a local Hardhat blockchain node.
   
    Run a few test transactions.

If everything works as expected, you should see a long log ending with something like this.

```
hw  | eth_sendRawTransaction
hw  |   Contract call:       TestToken#transfer
hw  |   Transaction:         0xc5668faf3f41b94d4c3fae4c8e4631854993e9d4cbf9321ada8b223bbfedd000
hw  |   From:                0x90f79bf6eb2c4f870365e785982e1f101e93b906
hw  |   To:                  0x057ef64e23666f000b34ae31332854acbd1c8544
hw  |   Value:               0 ETH
hw  |   Gas used:            51541 of 51541
hw  |   Block #2:            0x74af920b3df63288d6c0177ae236bf6915798d7ffc0136ebdbbf12c47db8d1e7
hw  | 
hw  | Transaction Hash: 0xc5668faf3f41b94d4c3fae4c8e4631854993e9d4cbf9321ada8b223bbfedd000
```

If there are no errors, it means that all necessary tooling is set up correctly.

5. **Important:**
Clear the Unsecure Known Key: Reinitialize the hardware to remove the unsecured known key. This step is crucial. Never use the hardware wallet with a known key outside of testing.

**Initialization**

You have two options for initializing the wallet:

1. With a New Random Key
Generate a new random key during initialization.
```./init.sh ```

3. Importing an Existing Key
To import a key, use the command:
```./init.sh /path/to/the/file/with/the/key/in/hex.key```



Make sure to follow these steps carefully, especially clearing the testing key, to ensure the wallet is secure for real use.


## 🔒 Security 


**B.T.N.H.W** was designed to address the following threats:

    
1. Workstation compromised by automated malware. "Automated malware" refers to an attack where the attacker cannot effectively communicate with the hardware wallet (HW) during the moment of its use.
2. Stolen or lost hardware wallet. The secret key should remain unrecoverable even with full physical access to the hardware wallet.
3. Accidental sharing of the key, such as an accidental push to version control systems.
4. Stolen workstation.

**Why is it "better than nothing"? What are the risks?**

Since the Raspberry Pi Pico lacks a security enclave to securely store the key in an unexportable manner, all keys on the device must be encrypted. The decryption key is stored on the workstation and is required to make the hardware wallet operational. Thus, there are two main takeaways:

1. If the generated wallet configuration (or the entire workstation) is stolen along with the hardware wallet, the secret key of your wallet is fully compromised — this is game over.
2. If the generated wallet configuration is lost, the hardware wallet becomes useless, and access to the secret key is lost forever.

Since the Raspberry Pi Pico has no screen (for visual confirmation) and mbedTLS (the crypto library) lacks a proper Keccak implementation, the hardware wallet signs the provided hash of a transaction. If an attacker has persistent and complete access to the workstation, they could attempt to sign a malicious hash or substitute data.




## 🛠️ What's inside?

The main building blocks are  

1. [pico-hsm](https://github.com/polhenarejos/pico-hsm)
2. [mbedtls](https://github.com/Mbed-TLS/mbedtls)
3. [RP2040](https://www.raspberrypi.com/documentation/microcontrollers/silicon.html#rp2040)


Pico-hsm firmware makes **RP2040** be a smart card, **pcsd** provides interface to  smart card, **B.T.N.H.W** is a toolsuite that integrates hardhat, smart-card and all needed to create ethereum-compatible signatures. 

All packed into docker container  with all important dependencies. 





