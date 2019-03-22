import asyncio
import config
import sys
import time

async def send_query(port, query, loop):
	
	# Connect to the specified server
	r, w = await asyncio.open_connection("127.0.0.1", port, loop = loop)

	# Send the query to the server and print what was sent
	w.write(query.encode())
	w.write_eof()
	print("SEND: {0}".format(query))

	# Asynchronously wait for the server response and print the response
	response = await r.read()
	print("RECV: {0}".format(response.decode()))

def main():

	# Check the command line argument length
	if len(sys.argv) != 2:
		print("ERROR: Incorrect number of arguments")
		sys.exit(1)

	# Check that a valid serverID was passed in
	serverID = sys.argv[1] 
	if serverID not in config.serverIDs:
		print("ERROR: Invalid server ID")
		sys.exit(1)

	# Get the event loop
	loop = asyncio.get_event_loop()

	# Try sending different test queries
	query = "\t\t\v\t\t\n    \f\t\fIAMAT\v\f\v\v   \t\ttaipei.com " \
		+ "+25.0339687+121.5622835 {0}\f\r\f\t\t\r".format(time.time())
	loop.run_until_complete(send_query(config.serverIDs[serverID], query, loop))
	
	query = "IAMAT \t\t\n\v\t\tucla.com +34.0689254-118.4473698 {0}"\
		.format(time.time())
	loop.run_until_complete(send_query(config.serverIDs[serverID], query, loop))

	query = "IAMAT taipei.com\t\t\v\n\t\t +37.8199328-122.4804438 {0}"\
		.format(time.time())
	loop.run_until_complete(send_query(config.serverIDs[serverID], query, loop))
	
	query = "WHATSAT \t\t\v\t\tucla.com 20 5"
	loop.run_until_complete(send_query(config.serverIDs[serverID], query, loop))

	query = "WHATSAT taipei.com 30\t\t\v\t\t 3"
	loop.run_until_complete(send_query(config.serverIDs[serverID], query, loop))

	# Close the loop
	loop.close()

if __name__ == "__main__":
	main()
