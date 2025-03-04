#!/bin/sh -e
#cp -r /root/node_modules /root/synth
npm config set update-notifier false


cd /hw

echo "Checking dependencies..."
#rm -rf ~/.npmrc
#rm -rf ~/.npm
#rm -rf ~/.node-gyp
#rm -rf /synth/node_modules
#npm cache clean -f
#npm install -g n
#n stable
#npm i --unsafe-perm

#npm config set user 0
#npm config set unsafe-perm true
#npm install -g npm@8.19.2
#npm i --save
#npm audit fix --force
#npm uninstall @gnosis.pm/safe-deployments
#npm audit fix
#sleep 100000
#npm i hardhat-deploy @openzeppelin/hardhat-
#npm install --save-dev hardhat
#npm i --save
#npm install typescript hardhat  hardhat-deploy ts-node #--unsafe-perm=true # hardhat-deploy-ethers hardhat-typechain hardhat-typechain ts-morph ts-node typescript ts-generator typechain@4.0.0 @typechain/ethers-v5 --unsafe-perm=true # --global




#./create-jsons-update-mpc.sh
#./create-jsons-update-owner.sh
#./settokenthreshold-v2.sh


#npx hardhat run tools/transferOwnership.js --network zklink_mainnet

if [ "$MODE" = "sign" ]; then
    echo "Signing the data..."
fi

if [ "$MODE" = "test" ]; then
    echo "Running deploy+transfer test..."
    rm ./tmp/*
    npx hardhat node &
    npx hardhat compile

    #building transaction


    #signing transaction
    PIN=$(jq -r '.PIN' $SIGNER)
    ID=$(jq -r '.KEY_ID' $SIGNER)

    [ -e "/run/pcscd/pcscd.comm" ] && sudo rm /run/pcscd/pcscd.comm
    #sudo rm /run/pcscd/pcscd.comm
    sudo service pcscd start
    #sudo pcscd --foreground  &
    #sleep 3
    python3 ./unlock.py
    sudo /usr/local/bin/pkcs11-tool -O
    #sudo service pcscd stop
    #exit 1
    npx hardhat run --network localhost scripts/unsigned_deploy.ts
    echo "pkcs11-tool --read-object --pin $PIN --id 0$ID --type pubkey > tmp/1pub.der"
    pkcs11-tool --read-object --pin $PIN --id 0$ID --type pubkey > tmp/1pub.der
    openssl ec -inform DER -outform PEM -in tmp/1pub.der -pubin -text > tmp/1pub.pem
    openssl ec -inform DER -outform PEM -in tmp/1pub.der -pubin -text | grep "    " | tr -d ' :\n' | cut -c 3- > tmp/1pub.eth

    pkcs11-tool  --sign --pin $PIN --id $ID --mechanism ECDSA -i tmp/submit_unsigned_tnx_hash_bin -o tmp/signature_openssl.der --signature-format openssl
    pkcs11-tool --sign --pin $PIN --id $ID --mechanism ECDSA -i tmp/submit_unsigned_tnx_hash_bin -o tmp/signature.der
    openssl pkeyutl -verify -pubin -inkey tmp/1pub.pem -in tmp/submit_unsigned_tnx_hash_bin -sigfile tmp/signature_openssl.der

    python3 ./tnxmaster.py
    npx hardhat run --network localhost scripts/send_tnx.ts
    #sudo service pcscd stop
    sleep 1
    #npx hardhat --version
    rm ./tmp/*

    npx hardhat run --network localhost scripts/unsigned_erc20_transfer.ts
    pkcs11-tool --read-object --pin $PIN --id $ID --type pubkey > tmp/1pub.der
    openssl ec -inform DER -outform PEM -in tmp/1pub.der -pubin -text > tmp/1pub.pem
    openssl ec -inform DER -outform PEM -in tmp/1pub.der -pubin -text | grep "    " | tr -d ' :\n' | cut -c 3- > tmp/1pub.eth

    pkcs11-tool  --sign --pin $PIN --id $ID --mechanism ECDSA -i tmp/submit_unsigned_tnx_hash_bin -o tmp/signature_openssl.der --signature-format openssl
    pkcs11-tool --sign --pin $PIN --id $ID --mechanism ECDSA -i tmp/submit_unsigned_tnx_hash_bin -o tmp/signature.der
    openssl pkeyutl -verify -pubin -inkey tmp/1pub.pem -in tmp/submit_unsigned_tnx_hash_bin -sigfile tmp/signature_openssl.der

    python3 ./tnxmaster.py
    #sudo service pcscd stop
    npx hardhat run --network localhost scripts/send_tnx.ts
    sudo service pcscd stop

fi


if [ "$MODE" = "testinithw" ]; then
    echo "Starting TEST HW init procedure..."
    [ -e "/run/pcscd/pcscd.comm" ] && sudo rm /run/pcscd/pcscd.comm
    #sudo rm /run/pcscd/pcscd.comm
    sudo service pcscd start
    pkcs11-tool -O
    data=$(python3 ./init_hw.py 1 '7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6')
    pkcs11-tool --pin $(jq -r '.PIN' $SIGNER) --id 31 --set-id 1 --type privkey
    pkcs11-tool -O
    #pkcs11-tool --login --login-type so --so-pin $(echo $data  | jq -r '.SOPIN') --init-pin --new-pin $(echo $data  | jq -r '.PIN')
    echo $data

fi

if [ "$MODE" = "inithw" ]; then
    echo "Starting HW init procedure..."
    #sudo rm /run/pcscd/pcscd.comm
    [ -e "/run/pcscd/pcscd.comm" ] && sudo rm /run/pcscd/pcscd.comm
    sudo service pcscd start
    pkcs11-tool -O
    data=$(python3 ./init_hw.py 1 0 )

    pkcs11-tool --pin $(echo $data | jq -r '.PIN') --id 31 --set-id 1 --type privkey
    pkcs11-tool -O
    echo $data
fi