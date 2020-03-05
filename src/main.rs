extern crate tiny_http;

use log::info;
use tiny_http::{
    Response,
    Server,
};

fn main() {
    simple_logger::init().unwrap();

    let server = Server::http("0.0.0.0:8080").unwrap();

    info!("Ready to greet on port 8080");

    for rq in server.incoming_requests() {
        info!("Received request from {}", rq.remote_addr());
        let response = Response::from_string("Hello world!".to_string());
        let _ = rq.respond(response);
    }
}

#[cfg(test)]
mod tests {

    #[test]
    fn it_works() {
        println!("It works!");
    }
}
