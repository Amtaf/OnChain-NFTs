const main = async()=>{
    const nftContractFactory=await hre.ethers.getContractFactory("MyEpicNFT")
    const nftContract=await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("contract deployed to:",nftContract.address);


    //call the function
    let txn=await nftContract.makeAnEpicNFT();
    //wait for it to be mined
    await txn.wait()

    //Mint another NFT for fun
    txn=await nftContract.makeAnEpicNFT();
    //wait for it to be mined
    await txn.wait()
}; 

const runMain = async () =>{
    try{
        await main();
        process.exit(0);
    }catch(error){
        console.log(error);
        process.exit(1);
    }
    
};

runMain()