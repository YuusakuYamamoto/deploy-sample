import { Controller, Get } from "@nestjs/common";
import { AppService } from "./app.service.js";
import { ApiTags } from "@nestjs/swagger";

@ApiTags("app")
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get("health")
  getHealth(): { status: string; timestamp: string } {
    return this.appService.getHealth();
  }
}
