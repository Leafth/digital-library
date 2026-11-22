import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { DatabaseModule } from './infrastructure/database/database.module.js';
import { EmprestimosModule } from './modules/emprestimos/emprestimos.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    DatabaseModule,
    EmprestimosModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
