import { Injectable } from "@nestjs/common";

@Injectable()
export class AppService {
  getHello(): string {
    return "Hello World! SDB Sample Backend is running!";
  }

  getHealth(): { status: string; timestamp: string } {
    return {
      status: "OK",
      timestamp: new Date().toISOString(),
    };
  }
}
