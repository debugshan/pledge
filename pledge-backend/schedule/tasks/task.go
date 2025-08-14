package tasks

import (
	"pledge-backend/db"
	"pledge-backend/schedule/common"
	"pledge-backend/schedule/services"
	"time"

	"github.com/jasonlvhit/gocron"
)

func Task() {

	// get environment variables
	common.GetEnv()

	// flush redis db
	err := db.RedisFlushDB()
	if err != nil {
		panic("clear redis error " + err.Error())
	}

	//init task
	services.NewPool().UpdateAllPoolInfo() //更新所有pool信息,从合约中获取最新数据
	services.NewTokenPrice().UpdateContractPrice()  //更新合约价格
	services.NewTokenSymbol().UpdateContractSymbol()  //更新合约symbol
	services.NewTokenLogo().UpdateTokenLogo()  //
	services.NewBalanceMonitor().Monitor()  //监控门限检查
	// services.NewTokenPrice().SavePlgrPrice()
	services.NewTokenPrice().SavePlgrPriceTestNet()  //设置测试网价格

	//run pool task
	s := gocron.NewScheduler()
	s.ChangeLoc(time.UTC)
	_ = s.Every(2).Minutes().From(gocron.NextTick()).Do(services.NewPool().UpdateAllPoolInfo) 
	_ = s.Every(1).Minute().From(gocron.NextTick()).Do(services.NewTokenPrice().UpdateContractPrice)
	_ = s.Every(2).Hours().From(gocron.NextTick()).Do(services.NewTokenSymbol().UpdateContractSymbol)
	_ = s.Every(2).Hours().From(gocron.NextTick()).Do(services.NewTokenLogo().UpdateTokenLogo)
	_ = s.Every(30).Minutes().From(gocron.NextTick()).Do(services.NewBalanceMonitor().Monitor)
	//_ = s.Every(30).Minutes().From(gocron.NextTick()).Do(services.NewTokenPrice().SavePlgrPrice)
	_ = s.Every(30).Minutes().From(gocron.NextTick()).Do(services.NewTokenPrice().SavePlgrPriceTestNet)
	<-s.Start() // Start all the pending jobs

}
