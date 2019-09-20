package saic.research.webservice1;

import java.util.concurrent.Executor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.web.client.RestTemplate;

import saic.research.webservice1.controller.Webservice1Controller;
import saic.research.webservice1.util.Webservice1Properties;


@ComponentScan(basePackages = { "saic.research.webservice1" })
@SpringBootApplication
@EnableAsync
@EnableConfigurationProperties({
	Webservice1Properties.class
})
public class Webservice1Application {
   
	public static void main(String[] args) {
		SpringApplication.run(Webservice1Application.class, args);
	}

@Bean
public Executor asyncExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(2);
    executor.setQueueCapacity(500);
    executor.setThreadNamePrefix("SAFERUploadMicroService-");
    executor.initialize();
    return executor;
}

}
