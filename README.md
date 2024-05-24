# BUILD YOUR OWN HTTP SERVER - IN RUBY

An HTTP Server built in Ruby that provides ability to read & write files, echo the given argument, check if system is
up, and get the information of User Agent.

This project is developed following the CodeCrafters' BUILD YOUR OWN HTTP SERVER module.

## How to get it working

Make sure you have Ruby installed on your machine.

1. Clone the repository
2. Run the `server.rb` file with `--directory` flag followed by a directory you desire to make IO operations on. An
   example: `ruby server.rb --directory ~/`
3. Send REST Request via curl or any tool.

## Endpoints

| METHOD | PATH                        | REQ. HEADERS   | 
|--------|-----------------------------|----------------|
| GET    | /                           | -              |
| GET    | /echo/{strToEcho}           | -              |
| GET    | /user-agent                 | -              |
| GET    | /files/{fileNameToRetrieve} | -              |
| POST   | /files/{fileNameToWrite}    | Content-Length |

