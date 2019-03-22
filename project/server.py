import aiohttp
import asyncio
import config
import json
import sys
import time

backend = {}

def update_log(contents, prefix = ""):

	# Prefix the log entry if specified
	if prefix != "":
		contents = "{0}: {1}".format(prefix, contents)
	log.write("{0}\n".format(contents))
	log.flush()

def get_coordinates(coordinates):

	# First make sure the length is positive
	if len(coordinates) == 0:
		return None

	# Find the indices of the two signs
	signs = []
	for i in range(len(coordinates)):
		if coordinates[i] == "+" or coordinates[i] == "-":
			signs.append(i)

	# There must be exactly two signs
	if len(signs) != 2:
		return None

	# The first sign must be at index 0
	if signs[0] != 0:
		return None

	# Return the latitude and longitude from the string if possible
	location = None
	try:
		latitude = float(coordinates[:signs[1]])
		longitude = float(coordinates[signs[1]:])
		location = [latitude, longitude]
	except:
		pass
	return location

def is_valid_IAMAT(input_list):

	# If the IAMAT input does not have an exact length of 4, it is invalid
	if len(input_list) != 4:
		return False

	# Identify each expected parameter
	input_type = input_list[0]
	clientID = input_list[1]
	coordinates = input_list[2]
	timestamp = input_list[3]

	# If the input_type is not IAMAT, return immediately
	if input_type != "IAMAT":
		return False

	# If the clientID is only white space characters or is empty, return
	if clientID == "" or clientID.isspace() == True:
		return False

	# If the location field does not contain valid coordinates, it is invalid
	if get_coordinates(coordinates) is None:
		return False

	# Try converting the timestamp into a float to check if it is valid
	timestamp_check = None
	try:
		timestamp_check = float(timestamp)
	except:
		pass
	if timestamp_check is None:
		return False

	# All test cases passed, so we have a valid IAMAT input
	return True

def is_valid_WHATSAT(input_list):

	# If the WHATSAT input does not have an exact length of 4, it is invalid
	if len(input_list) != 4:
		return False

	# Identify each expected parameter
	input_type = input_list[0]
	clientID = input_list[1]
	radius = input_list[2]
	max_length = input_list[3]

	# If the input_type is not IAMAT, return immediately
	if input_type != "WHATSAT":
		return False

	# If the clientID is only white space characters or is empty, return
	if clientID == "" or clientID.isspace() == True:
		return False

	# Try converting the radius into a float to check if it is valid
	radius_check = None
	try:
		radius_check = float(radius)
	except:
		pass
	if radius_check is None:
		return False

	# Try converting the max_length into an int to check if it is valid
	max_length_check = None
	try:
		max_length_check = int(max_length)
	except:
		pass
	if max_length_check is None:
		return False
	if max_length_check < 0:
		return False

	# All test cases passed, so we have a valid WHATSAT input
	return True

def is_valid_FLOOD(input_list):

	# If the FLOOD input does not have an exact length of 6, it is invalid
	if len(input_list) != 6:
		return False

	# Identify each expected parameter
	input_type = input_list[0]
	serverID = input_list[1]
	time_difference = input_list[2]
	clientID = input_list[3]
	coordinates = input_list[4]
	timestamp = input_list[5]

	# If the input_type is not FLOOD, return immediately
	if input_type != "FLOOD":
		return False

	# If the serverID is not in our serverIDs list, return immediately
	if serverID not in config.serverIDs:
		return False

	# Time difference must start with +/- and end with a valid float
	if len(time_difference) < 1:
		return False
	if time_difference[0] != "+" and time_difference != "-":
		return False
	time_difference_check = None
	try:
		time_difference_check = float(time_difference[1:])
	except:
		pass
	if time_difference_check is None:
		return False

	# If the clientID is only white space characters or is empty, return
	if clientID == "" or clientID.isspace() == True:
		return False

	# If the location field does not contain valid coordinates, it is invalid
	if get_coordinates(coordinates) is None:
		return False

	# Try converting the timestamp into a float to check if it is valid
	timestamp_check = None
	try:
		timestamp_check = float(timestamp)
	except:
		pass
	if timestamp_check is None:
		return False

	# All test cases passed, so we have a valid FLOOD input
	return True

def is_valid(input_list):

	# If the list is empty, we have an invalid input
	if len(input_list) == 0:
		return None

	# Check the type of input
	input_type = input_list[0]
	if input_type == "IAMAT":
		if is_valid_IAMAT(input_list) == False:
			return None
	elif input_type == "WHATSAT":
		if is_valid_WHATSAT(input_list) == False:
			return None
	elif input_type == "FLOOD":
		if is_valid_FLOOD(input_list) == False:
			return None
	else:
		return None
	return input_type

def update_backend(input_list):

	# Identify each expected parameter
	input_type = input_list[0]
	serverID = input_list[1]
	time_difference = input_list[2]
	clientID = input_list[3]
	coordinates = input_list[4]
	timestamp = input_list[5]

	# If the clientID exists in the backend
	if clientID in backend:

		# Fetch the relevant record
		record = backend[clientID]

		# If what we have is newer than the received input, simply return
		record_timestamp = record[4]
		if record_timestamp >= timestamp:
			return
	
	# Otherwise, update the backend with the new record and propagate flood
	backend[clientID] = input_list[1:]

	# Propagate the flood to the other servers with this new record
	asyncio.ensure_future(flood(clientID))

def calculate_time_difference(time1, time2):
	time_difference = time2 - time1
	time_str = str(time_difference)

	# Add a + if the time difference is not negative
	if time_difference >= 0:
		time_str = "+{0}".format(time_str)
	return time_str

async def flood(clientID):

	# Look up the servers that this server is allowed to communicate with
	serverID = sys.argv[1]
	for neighbor in config.herd_links[serverID]:

		# Try connecting to the current server
		update_log("Trying to connect to server {0}".format(neighbor),
			prefix = "STATUS")
		try:
			r, w = await asyncio.open_connection("127.0.0.1",
				config.serverIDs[neighbor], loop = server_loop)
			update_log("Successfully connected to server {0}".format(neighbor),
				prefix = "STATUS")
			
			# Build the flood propagation query to send to the other servers
			record = backend[clientID]
			record_str = " ".join(record)
			flood_query = "FLOOD {0}".format(record_str)
			w.write(flood_query.encode())
			w.write_eof()
			await w.drain()
			w.close()

			# Update the log file that a FLOOD message was sent
			update_log(flood_query, prefix = "SEND")
		except:

			# Update the log file if the neighboring server is down
			update_log("Could not connect to server {0}".format(neighbor),
				prefix = "STATUS")
			pass


async def fetch_response(input_list, timestamp):
	valid_input_type = is_valid(input_list)
	response = ""
	invalid_response = "? {0}".format(" ".join(input_list))
	if valid_input_type == "IAMAT":

		# Calculate the time difference between now and the client timestamp
		time_difference = calculate_time_difference(float(input_list[3]),
			timestamp)

		# Create and save the backend record
		serverID = sys.argv[1]
		record = [serverID, time_difference] + input_list[1:]
		clientID = input_list[1]
		backend[clientID] = record

		# Create the response to send to the client
		record_str = " ".join(record)
		response = "AT {0}".format(record_str)

		# Flood this client's query to the other reachable servers in the herd
		asyncio.ensure_future(flood(clientID))
	elif valid_input_type == "WHATSAT":

		# Fetch the required parameters from the input
		clientID = input_list[1]
		radius = input_list[2]
		max_length = input_list[3]

		# Check if the backend has a record for the given client
		if clientID in backend:

			# Fetch the record from the backend
			record = backend[clientID]

			# Build the Google Places API query
			coords = get_coordinates(record[3])
			coords_param = ",".join([str(coords[0]), str(coords[1])])
			radius_param = 1000 * float(radius)
			max_length_param = int(max_length)
			GET_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch"\
				+ "/json?key={0}&location={1}&radius={2}".format(
				config.KEY, coords_param, radius_param)

			# Create the response to send to the client
			record_str = " ".join(record)
			response = "AT {0}".format(record_str)
			async with aiohttp.ClientSession() as sesh:
				async with sesh.get(GET_URL) as res:
					json_obj = None
					try:
						json_obj = await res.json()	
					except:
						pass
					if json_obj is not None:

						# Only keep the first max_length results
						json_obj["results"] = json_obj["results"][:int(
							max_length_param)]
						response += "\n{0}\n\n".format(json.dumps(
							json_obj, indent = 3))
					else:
						response = invalid_response
		else:
			response = invalid_response
	else:
		response = invalid_response
	return response

async def listen(r, w):

	# Wait for a query and only stop reading until we see an EOF
	input_line = await r.read()

	# Save the timestamp of when the server received the query
	timestamp = time.time()

	# Decode the user input
	input_text = input_line.decode()

	# Clean the input of white space before, within, and after the user's input
	input_list = input_text.strip().split()

	# Update the log file
	update_log(" ".join(input_list), prefix = "RECV")

	# First check if it is a flood to update the backend
	valid_input_type = is_valid(input_list)
	if valid_input_type == "FLOOD":
		update_backend(input_list)
	else:

		# Fetch and write the correct response to the client, write EOF
		response = await fetch_response(input_list, timestamp)
		w.write(response.encode())
		w.write_eof()

		# Update the log file
		update_log(response, prefix = "SEND")
		await w.drain()

def main():

	# Define global variables
	global log
	global server_loop

	# Check the command line argument length
	if len(sys.argv) != 2:
		print("ERROR: Incorrect number of arguments")
		sys.exit(1)

	# Check that a valid serverID was passed in
	serverID = sys.argv[1] 
	if serverID not in config.serverIDs:
		print("ERROR: Invalid server ID")
		sys.exit(1)

	# Create the log file and open with writing permissions
	log_filename = "{0}.txt".format(serverID)
	log = open(log_filename, "w+")

	# Run the server event loop on the function listen
	server_loop = asyncio.get_event_loop()
	server_init = asyncio.start_server(listen, "127.0.0.1",
		config.serverIDs[serverID], loop = server_loop)
	server_instance = server_loop.run_until_complete(server_init)

	# Continually listen for user input until a keyboard interrupt happens
	try:
		server_loop.run_forever()
	except KeyboardInterrupt:
		pass

	# Close the log file and the server instance
	log.close()
	server_instance.close()
	server_loop.run_until_complete(server_instance.wait_closed())
	server_loop.close()

if __name__ == "__main__":
	main()
