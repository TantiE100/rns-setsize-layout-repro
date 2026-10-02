import { ScrollView, StyleSheet, Text, View } from 'react-native'

const ROWS = Array.from({ length: 150 }, (_, index) => index)

export function Rows({ label }: { label: string }) {
  return (
    <ScrollView>
      {ROWS.map((row) => (
        <View key={row} style={styles.row}>
          <View style={styles.thumb} />
          <View style={styles.body}>
            <Text style={styles.title}>
              {label} {row}
            </Text>
            <Text style={styles.subtitle}>Nothing here changes while scrolling</Text>
          </View>
        </View>
      ))}
    </ScrollView>
  )
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: 12.5, padding: 12.5 },
  thumb: { width: 56.5, height: 40.5, borderRadius: 6, backgroundColor: '#8ab4f8' },
  body: { flex: 1, gap: 2.5 },
  title: { fontSize: 16, fontWeight: '600' },
  subtitle: { fontSize: 13, color: '#666' }
})
