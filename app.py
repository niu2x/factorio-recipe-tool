from flask import Flask
from flask import request, redirect, url_for
from flask import render_template
import os
import subprocess

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index_page():
	return redirect(url_for('hello_world', last_graph='_'))

@app.route('/fuck/<path:last_graph>', methods=['POST', 'GET'])
def hello_world(last_graph):

	tmp_graph = None

	if last_graph != '_':
		tmp_graph = last_graph

	while request.method == 'POST':
		# return str()

		tmp_dot = os.tmpnam()
		tmp_graph = os.tmpnam().replace('/', '_')
		tmp_graph = 'static/tmp/' + tmp_graph

		p = subprocess.Popen(['lua5.3', "main.lua", "resolve"], stdout = subprocess.PIPE, stdin = subprocess.PIPE, stderr=subprocess.PIPE)
		for v in request.form.getlist('products'):
			p.stdin.write(v.encode('utf-8') + '\n')
		p.stdin.close()

		if p.wait() != 0:
			tmp_graph = None
			return p.stderr.read().replace('\n', '<br/>')

		graph_dot = p.stdout.read()

		fp = file(tmp_dot, 'w')
		fp.write(graph_dot)
		fp.close()
		del fp

		p = subprocess.Popen(['dot', "-Tpng", "-o", tmp_graph, tmp_dot ], stderr=subprocess.PIPE)
		if p.wait() != 0:
			tmp_graph = None
			return p.stderr.read().replace('\n', '<br/>')

		os.unlink(tmp_dot)

		return redirect(url_for('hello_world', last_graph = tmp_graph))


	fp = file('non-final-items.cfg')

	non_final_items = []

	for line in fp.readlines():
		data = line.split(',')
		if len(data) == 2:
			non_final_items.append({'id':data[0], 'display_name':data[1].decode('utf-8')})
	non_final_items.sort()
	fp.close()
	del fp

	print 'tmp_graph', tmp_graph
	return render_template('index.html', non_final_items = non_final_items, graph = tmp_graph)

def gen_graph():
	error = None
	
	return 'only support post'
